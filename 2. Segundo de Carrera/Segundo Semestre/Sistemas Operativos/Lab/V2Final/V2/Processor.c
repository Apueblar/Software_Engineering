#include "Processor.h"
#include "ProcessorBase.h"
#include "OperatingSystem.h"
#include "OperatingSystemBase.h"
#include "Buses.h"
#include <stdio.h>
#include <string.h>
#include "Wrappers.h"
#include "Simulator.h"

// Internals Functions prototypes
void Processor_ManageInterrupts();

// External data
extern char *InstructionNames[];

// Processor registers
int registerPC_CPU; // Program counter
int registerAccumulator_CPU; // Accumulator
BUSDATACELL registerIR_CPU; // Instruction register
unsigned int registerPSW_CPU = 128; // Processor state word, initially protected mode
int registerMAR_CPU; // Memory Address Register
BUSDATACELL registerMBR_CPU; // Memory Buffer Register
int registerCTRL_CPU; // Control bus Register

int registerA_CPU; // General purpose register
int registerB_CPU; // General purpose register
int registerC_CPU; // System purpose register
int registerD_CPU; // Sleep processes register V2 - Ex5

int registerSP_CPU; // Stack pointer register
int interruptLines_CPU; // Processor interrupt lines

// interrupt vector table: an array of handle interrupt memory addresses routines  
int interruptVectorTable[INTERRUPTTYPES];

// For PSW show "M-------X---FNZS"
char pswmask []="----------------"; 


// Initialization of the interrupt vector table
void Processor_InitializeInterruptVectorTable(int interruptVectorInitialAddress) {
	int i;
	for (i=0; i< INTERRUPTTYPES;i++) { // Inicialice all to inicial IRET
		interruptVectorTable[i]=interruptVectorInitialAddress-2;  
	}

	interruptVectorTable[SYSCALL_BIT]=interruptVectorInitialAddress;  // SYSCALL_BIT=2
	interruptVectorTable[EXCEPTION_BIT]=interruptVectorInitialAddress+NUMBER_OF_CPU_INSTRUCTIONS_PER_INTERRUPT; // EXCEPTION_BIT=6
	interruptVectorTable[CLOCKINT_BIT]=interruptVectorInitialAddress+2*NUMBER_OF_CPU_INSTRUCTIONS_PER_INTERRUPT; // CLOCKINT_BIT=9
}

// Fetch an instruction from main memory and put it in the IR register
int Processor_FetchInstruction() {

	// The instruction must be located at the logical memory address pointed by the PC register
	registerMAR_CPU=registerPC_CPU;
	// Send to the MMU the address in which the reading has to take place: use the address bus for this
	Buses_write_AddressBus_From_To(CPU, MMU);
	// Tell the main memory controller to read
	registerCTRL_CPU=CTRLREAD;
	Buses_write_ControlBus_From_To(CPU,MMU);

	if (registerCTRL_CPU & CTRL_SUCCESS) {
		// All the read data is stored in the MBR register. Because it is an instruction
		// we have to copy it to the IR register
		memcpy((void *) (&registerIR_CPU), (void *) (&registerMBR_CPU), sizeof(BUSDATACELL));
		// Show initial part of HARDWARE message with Operation Code and operands
		// Show message: operationCode operand1 operand2
		char codedInstruction[13]; // Coded instruction with separated fields to show
		Processor_GetCodedInstruction(codedInstruction,registerIR_CPU);
		ComputerSystem_DebugMessage(TIMED_MESSAGE,68, HARDWARE, codedInstruction);
	}
	else {
		// Show message: "_ _ _ "
		ComputerSystem_DebugMessage(TIMED_MESSAGE,100,HARDWARE,"_ _ _\n");
		return CPU_FAIL;
	}
	return CPU_SUCCESS;
}


// Decode and execute the instruction in the IR register
void Processor_DecodeAndExecuteInstruction() {
	int tempAcc; // for save accumulator if necesary

	// Decode
	int operationCode=Processor_DecodeOperationCode(registerIR_CPU);
	int operand1=Processor_DecodeOperand1(registerIR_CPU);
	int operand2=Processor_DecodeOperand2(registerIR_CPU);

	Processor_DeactivatePSW_Bit(OVERFLOW_BIT);

	// Execute
	switch (operationCode) {
	  
		// Instruction ADD
		case ADD_INST:
			registerAccumulator_CPU= operand1 + operand2;
			Processor_CheckOverflow(operand1,operand2,REGISTERACCUMULATOR_CPU);//check accumulator
			registerPC_CPU++;
			break;
		
		// Instruction SHIFT (SAL and SAR)
		case SHIFT_INST: 
			  if (operand1<0) { // SAL do not allow more than 31 bists shift...
			  	int oldAcc=registerAccumulator_CPU;
			  	registerAccumulator_CPU <<= ((-operand1) & 0x1f);// unnecesary & because Intel make this way...
			  	if ((registerAccumulator_CPU & (1<<(sizeof(int)*8-1)))^(oldAcc & (1<<(sizeof(int)*8-1)))) {// some bit overflow...
					Processor_ActivatePSW_Bit(OVERFLOW_BIT);
				}
			  } 
			  else	// SAR do not allow more than 31 bists shift...
			  	registerAccumulator_CPU >>= operand1 & 0x1f;// unnecesary & because Intel make this way...
			  
			  registerPC_CPU++;
			  break;
		
		// Instruction DIV
		case DIV_INST: 
			if (operand2 == 0)
				Processor_RaiseInterrupt(EXCEPTION_BIT); 
			else {
				registerAccumulator_CPU=operand1 / operand2;
				registerPC_CPU++;
			}
			break;
			  
		// Instruction TRAP
		case TRAP_INST: 
			Processor_RaiseInterrupt(SYSCALL_BIT);
			registerC_CPU=operand1;
			registerD_CPU=operand2;
			registerPC_CPU++;
			break;
		
		// Instruction NOP
		case NOP_INST: 
			registerPC_CPU++;
			break;
			  
		// Instruction JUMP
		case JUMP_INST: 
			registerPC_CPU+= operand1;
			break;
			  
		// Instruction ZJUMP
		case ZJUMP_INST: // Jump if ZERO_BIT on
			if (Processor_PSW_BitState(ZERO_BIT))
				registerPC_CPU+= operand1;
			else
				registerPC_CPU++;
			break;

		// Instruction WRITE
		case WRITE_INST: 
			registerMAR_CPU=operand1;
			// Send to the MMU controller the address in which the writing has to take place: use the address bus for this
			Buses_write_AddressBus_From_To(CPU, MMU);

			switch (operand2) {
				case REGISTERACCUMULATOR_CPU:
					registerMBR_CPU.cell=registerAccumulator_CPU;
					break;
				case REGISTERA_CPU:
					registerMBR_CPU.cell=registerA_CPU;
					break;
				case REGISTERB_CPU:
					registerMBR_CPU.cell=registerB_CPU;
					break;
				default:
					registerMBR_CPU.cell=registerAccumulator_CPU;
			}
			// Send to the main memory controller the data to be written: use the data bus for this
			Buses_write_DataBus_From_To(CPU, MAINMEMORY);
			// Tell the MMU controller to write
			registerCTRL_CPU=CTRLWRITE;
			Buses_write_ControlBus_From_To(CPU,MMU);
			registerPC_CPU++;
			break;

		// Instruction READ
		case READ_INST: 
			registerMAR_CPU=operand1;
			// Send to the MMU controller the address in which the reading has to take place: use the address bus for this
			Buses_write_AddressBus_From_To(CPU, MMU);
			// Tell the MMU controller to read
			registerCTRL_CPU=CTRLREAD;
			Buses_write_ControlBus_From_To(CPU,MMU);
			// Copy the read data to the register indicated in operand2
			switch (operand2) {
				case REGISTERACCUMULATOR_CPU:
					registerAccumulator_CPU=registerMBR_CPU.cell;
					break;
				case REGISTERA_CPU:
					registerA_CPU=registerMBR_CPU.cell;
					break;
				case REGISTERB_CPU:
					registerB_CPU=registerMBR_CPU.cell;
					break;
				default:
					registerAccumulator_CPU=registerMBR_CPU.cell;
			}
			registerPC_CPU++;
			break;

		// Instruction INC
		case INC_INST: 
			switch (operand2) {
				case REGISTERACCUMULATOR_CPU:
					tempAcc=registerAccumulator_CPU;
					registerAccumulator_CPU += operand1;
				break;
				case REGISTERA_CPU:
					tempAcc=registerA_CPU;
					registerA_CPU += operand1;
				break;
				case REGISTERB_CPU:
					tempAcc=registerB_CPU;
					registerB_CPU+=operand1;
				break;
				default:
					tempAcc=registerAccumulator_CPU;
					registerAccumulator_CPU += operand1;
				break;
			}
			Processor_CheckOverflow(tempAcc,operand1,operand2);
			registerPC_CPU++;
			break;

		// Instruction HALT
		case HALT_INST: 
			if (!Processor_PSW_BitState(EXECUTION_MODE_BIT)) { // Checks if it is run in with privileges
				Processor_RaiseInterrupt(EXCEPTION_BIT);
				break;
			}
			Processor_ActivatePSW_Bit(POWEROFF_BIT);
			break;
			  
		// Instruction OS
		case OS_INST: // Make a operating system routine in entry point indicated by operand1
			if (!Processor_PSW_BitState(EXECUTION_MODE_BIT)) { // Checks if it is run in with privileges
				Processor_RaiseInterrupt(EXCEPTION_BIT);
				return;
			}
			// Show final part of HARDWARE message with CPU registers
			// Show message: " (PC: registerPC_CPU, Accumulator: registerAccumulator_CPU, PSW: registerPSW_CPU [Processor_ShowPSW()]\n
			ComputerSystem_DebugMessage(NO_TIMED_MESSAGE,69, HARDWARE, InstructionNames[operationCode],operand1,operand2,OperatingSystem_GetExecutingProcessID(),registerPC_CPU,registerAccumulator_CPU,registerPSW_CPU,Processor_ShowPSW(),interruptLines_CPU);

			// Not all operating system code is executed in simulated processor, but really must do it... 
			OperatingSystem_InterruptLogic(operand1);
			registerPC_CPU++;
			// Update PSW bits (ZERO_BIT, NEGATIVE_BIT, ...)
			Processor_UpdatePSW();
			return; // Note: message show before... for operating system messages after...

		// Instruction IRET
		case IRET_INST: // Return from a interrupt handle manager call
			if (!Processor_PSW_BitState(EXECUTION_MODE_BIT)) { // Checks if it is run in with privileges
				Processor_RaiseInterrupt(EXCEPTION_BIT);
				break;
			}
			registerPSW_CPU=Processor_PopFromSystemStack();
			registerPC_CPU=Processor_PopFromSystemStack();
			break;

		case MOV_INST: // Copy data between processor registers
			switch (operand1) {
				case REGISTERACCUMULATOR_CPU:
					tempAcc=registerAccumulator_CPU;
				break;
				case REGISTERA_CPU:
					tempAcc=registerA_CPU;
				break;
				case REGISTERB_CPU:
					tempAcc=registerB_CPU;
				break;
				default:
					tempAcc=registerAccumulator_CPU;
				break;
			}
			switch (operand2) {
				case REGISTERACCUMULATOR_CPU:
					registerAccumulator_CPU=tempAcc;
				break;
				case REGISTERA_CPU:
					registerA_CPU=tempAcc;
				break;
				case REGISTERB_CPU:
					registerB_CPU=tempAcc;
				break;
				default:
					registerAccumulator_CPU=tempAcc;
				break;
			}
			registerPC_CPU++;
			break;

		// Instruction RET
		case RET_INST: // Return from a subroutine
			registerPC_CPU=Processor_CopyFromRawMemory(registerSP_CPU++);
			break;		

		// Instruction CALL
		case CALL_INST: // Jump to a subroutine
			Processor_CopyInRawMemory(--registerSP_CPU,registerPC_CPU+1);
			registerPC_CPU+=operand1;
			break;

		// Instruction MEMADD : acc = register(op1) + read(op2)
		case MEMADD_INST: 
			// Load memory address into MAR register
			registerMAR_CPU = operand2;
			
			// Send memory address to MMU via the address bus
			Buses_write_AddressBus_From_To(CPU, MMU);
			
			// Request memory read operation
			registerCTRL_CPU = CTRLREAD;
			Buses_write_ControlBus_From_To(CPU, MMU);
			
			// Read the memory value into value2
			int value2 = registerMBR_CPU.cell;

			// Get the value of registerID
			int value1 = 0;
			switch (operand1) {
				case REGISTERACCUMULATOR_CPU:
					value1 = registerAccumulator_CPU;
					break;
				case REGISTERA_CPU:
					value1 = registerA_CPU;
					break;
				case REGISTERB_CPU:
					value1 = registerB_CPU;
					break;
				default:
					value1 = registerAccumulator_CPU;
					break;
			}

			// Perform addition and store in accumulator
			registerAccumulator_CPU = value1 + value2;

			// Check for overflow
			Processor_CheckOverflow(value1, value2, REGISTERACCUMULATOR_CPU);

			// Increment program counter
			registerPC_CPU++;
			break;

		// Unknown instruction
		default : 
			operationCode=NONEXISTING_INST;
			registerPC_CPU++;
			break;
	}
	
	// Update PSW bits (ZERO_BIT, NEGATIVE_BIT, ...)
	Processor_UpdatePSW();
	
	// Show final part of HARDWARE message with	CPU registers
	// Show message: " (PC: registerPC_CPU, Accumulator: registerAccumulator_CPU, PSW: registerPSW_CPU [Processor_ShowPSW()]\n
	ComputerSystem_DebugMessage(NO_TIMED_MESSAGE,69, HARDWARE, InstructionNames[operationCode],operand1,operand2,OperatingSystem_GetExecutingProcessID(),registerPC_CPU,registerAccumulator_CPU,registerPSW_CPU,Processor_ShowPSW(),interruptLines_CPU);
}
	
	
// Hardware interrupt processing
void Processor_ManageInterrupts() {
	if (!Processor_PSW_BitState(INTERRUPT_MASKED_BIT)) {
		int i;
		for (i=0;i<INTERRUPTTYPES;i++)
			// If an 'i'-type interrupt is pending
			if (Processor_GetInterruptLineStatus(i)) {
				// Deactivate interrupt
				Processor_ACKInterrupt(i); // i = 0 -> Desmarca the activated exception bit
				// Copy PC and PSW registers in the system stack -> To later come back to the executing process
				Processor_PushInSystemStack(registerPC_CPU);
				Processor_PushInSystemStack(registerPSW_CPU);	
				// Activate protected excution mode (privileged mode)
				Processor_ActivatePSW_Bit(EXECUTION_MODE_BIT);
				// Disable posible interrupts to current interrupts
				Processor_ActivatePSW_Bit(INTERRUPT_MASKED_BIT);
				// Call the appropriate OS interrupt-handling routine setting PC register
				registerPC_CPU=interruptVectorTable[i];
				break; // Don't process another interrupt
			}
	}
}

char * Processor_ShowPSW(){
	strcpy(pswmask,"----------------");
	int tam=strlen(pswmask)-1;
	if (Processor_PSW_BitState(EXECUTION_MODE_BIT))
		pswmask[tam-EXECUTION_MODE_BIT]='X';
	if (Processor_PSW_BitState(OVERFLOW_BIT))
		pswmask[tam-OVERFLOW_BIT]='F';
	if (Processor_PSW_BitState(NEGATIVE_BIT))
		pswmask[tam-NEGATIVE_BIT]='N';
	if (Processor_PSW_BitState(ZERO_BIT))
		pswmask[tam-ZERO_BIT]='Z';
	if (Processor_PSW_BitState(POWEROFF_BIT))
		pswmask[tam-POWEROFF_BIT]='S';
	if (Processor_PSW_BitState(INTERRUPT_MASKED_BIT))
		pswmask[tam-INTERRUPT_MASKED_BIT]='M';
	return pswmask;
}


/////////////////////////////////////////////////////////
//  New functions below this line  //////////////////////
