#include "Simulator.h"
#include "OperatingSystem.h"
#include "OperatingSystemBase.h"
#include "MMU.h"
#include "Processor.h"
#include "Buses.h"
#include "Heap.h"
#include <string.h>
#include <ctype.h>
#include <stdlib.h>
#include <time.h>

// Enumereted type containing the names of the states of a process
char * statesNames[5]={"NEW","READY","EXECUTING","BLOCKED","EXIT"};

// Enumereted type containing the names of the exception types
char * exceptionsNames[4]={"division by zero", "invalid processor mode", "invalid address", "invalid instruction"};

// Enumereted type containing the messages of the partitions and tables
char * messagesPartitions[4]={"before allocating memory", "after allocating memory", "before releasing memory", "after releasing memory"};

// Functions prototypes
void OperatingSystem_PCBInitialization(int, int, int, int, int);
void OperatingSystem_MoveToTheREADYState(int);
void OperatingSystem_Dispatch(int);
void OperatingSystem_RestoreContext(int);
void OperatingSystem_SaveContext(int);
void OperatingSystem_TerminateExecutingProcess();
int OperatingSystem_LongTermScheduler();
void OperatingSystem_PreemptRunningProcess();
int OperatingSystem_CreateProcess(int);
int OperatingSystem_ObtainMainMemory(int);
int OperatingSystem_ShortTermScheduler();
int OperatingSystem_ExtractFromReadyToRun();
void OperatingSystem_HandleException();
void OperatingSystem_HandleSystemCall();
// MINE
void OperatingSystem_PrintReadyToRunQueue();
void OperatingSystem_HandleClockInterrupt();
void OperatingSystem_MoveToTheBLOCKEDState(int);
int OperatingSystem_ExtractFromBlocked();
void OperatingSystem_BlockRunningProcess();
int OperatingSystem_CheckBlocked();
int OperatingSystem_CheckPriority();
int OperatingSystem_CheckChangeProcessWithMorePriority();
void OperatingSystem_DivideHole(int, int, char[], int);
void OperatingSystem_MovePartitionsToRightFrom(int);
void OperatingSystem_MovePartitionsToLeftFrom(int);
void OperatingSystem_ReleaseMainMemory(int);
int OperatingSystem_CoalesceHoles(int);

// The process table
// PCB processTable[PROCESSTABLEMAXSIZE];
PCB * processTable;

// Size of the memory occupied for the OS
int OS_MEMORY_SIZE=32;

// Address base for OS code in this version
int OS_address_base; 

// Identifier of the current executing process
int executingProcessID=NOPROCESS;

// Identifier of the System Idle Process
int sipID;

// Initial PID for assignation (Not assigned)
int initialPID=-1;

// Used to count the number of interrupts raised by the clock
int numberOfClockInterrupts = 0;

// Begin indes for daemons in programList
// int baseDaemonsInProgramList; 

// Array that contains the identifiers of the READY processes
// heapItem readyToRunQueue[NUMBEROFQUEUES][PROCESSTABLEMAXSIZE];
heapItem *readyToRunQueue[NUMBEROFQUEUES];
// int numberOfReadyToRunProcesses[0]={0};
int numberOfReadyToRunProcesses[NUMBEROFQUEUES]={0,0};
char *queueNames[NUMBEROFQUEUES]={"USER","DAEMONS"};

// Heap with blocked processes sort by when to wakeup
heapItem *sleepingProcessesQueue;
int numberOfSleepingProcesses=0;

// Variable containing the number of not terminated user processes
int numberOfNotTerminatedUserProcesses=0;

// char DAEMONS_PROGRAMS_FILE[MAXFILENAMELENGTH]="teachersDaemons";

int MAINMEMORYSECTIONSIZE = 60;

extern int MAINMEMORYSIZE;

int PROCESSTABLEMAXSIZE = 4;

// Initial set of tasks of the OS
void OperatingSystem_Initialize(int programsFromFileIndex) {
	
	int i, selectedProcess;
	FILE *programFile; // For load Operating System Code
	
	// In this version, with original configuration of memory size (300) and number of processes (4)
	// every process occupies a 60 positions main memory chunk 
	// and OS code and the system stack occupies 60 positions 

	OS_address_base = MAINMEMORYSIZE - OS_MEMORY_SIZE;

	MAINMEMORYSECTIONSIZE = OS_address_base / PROCESSTABLEMAXSIZE;

	if (initialPID<0) // if not assigned in options...
		initialPID = PROCESSTABLEMAXSIZE - 1;
	
	// Space for the processTable
	processTable = (PCB *) malloc(PROCESSTABLEMAXSIZE*sizeof(PCB));
	
	// Space for the ready to run queues (one queue initially... NOW 2)
	readyToRunQueue[USERPROCESSQUEUE] = Heap_create(PROCESSTABLEMAXSIZE);
	readyToRunQueue[DAEMONSQUEUE] = Heap_create(PROCESSTABLEMAXSIZE);

	// Space for the sleeping processes
	sleepingProcessesQueue = Heap_create(PROCESSTABLEMAXSIZE);

	programFile=fopen("OperatingSystemCode", "r");
	if (programFile==NULL){
		// Show red message "FATAL ERROR: Missing Operating System!\n"
		ComputerSystem_DebugMessage(NO_TIMED_MESSAGE,99,SHUTDOWN,"FATAL ERROR: Missing Operating System!\n");
		exit(1);		
	}

	// Obtain the memory requirements of the program
	int processSize=OperatingSystem_ObtainProgramSize(programFile);

	// Load Operating System Code
	OperatingSystem_LoadProgram(programFile, OS_address_base, processSize);
	
	OperatingSystem_InitializePartitionsAndHolesTable(OS_address_base);

	// Process table initialization (all entries are free)
	for (i=0; i<PROCESSTABLEMAXSIZE;i++){
		processTable[i].busy=0; // Explains if the position is ocupied or not
		processTable[i].initialPhysicalAddress=-1;
		processTable[i].processSize=-1;
		processTable[i].copyOfSPRegister=-1;
		processTable[i].state=-1;
		processTable[i].priority=-1;
		processTable[i].copyOfPCRegister=-1;
		processTable[i].copyOfPSWRegister=-1;
		processTable[i].programListIndex=-1;
		processTable[i].copyOfAccumulatorRegister=0;
		processTable[i].copyOfRegisterA=0;
		processTable[i].copyOfRegisterB=0;
		processTable[i].whenToWakeUp=-1;
	}
	// Initialization of the interrupt vector table of the processor
	Processor_InitializeInterruptVectorTable(OS_address_base+2);
	
	// Include in program list all user or system daemon processes
	OperatingSystem_PrepareDaemons(programsFromFileIndex);

	// Filling the ArrivalTimeQueue
	ComputerSystem_FillInArrivalTimeQueue();

	// Printing
	OperatingSystem_PrintStatus();
	
	// Create all user processes from the information given in the command line
	if (OperatingSystem_LongTermScheduler() > 0) { OperatingSystem_PrintStatus(); }
	
	if (numberOfNotTerminatedUserProcesses == 0 && OperatingSystem_IsThereANewProgram() == EMPTYQUEUE) { // 0 processes created and empty queue
		Processor_SetSSP(MAINMEMORYSIZE-1);
		OperatingSystem_Dispatch(sipID);
		Processor_SetPC(OS_address_base);
		OperatingSystem_ReadyToShutdown();
		return;
	}
	
	if (strcmp(programList[processTable[sipID].programListIndex]->executableName,"SystemIdleProcess")
		&& processTable[sipID].state==READY) {
		// Show red message "FATAL ERROR: Missing SIP program!\n"
		ComputerSystem_DebugMessage(NO_TIMED_MESSAGE,99,SHUTDOWN,"FATAL ERROR: Missing SIP program!\n");
		exit(1);		
	}

	// At least, one process has been created
	// Select the first process that is going to use the processor
	selectedProcess=OperatingSystem_ShortTermScheduler();

	Processor_SetSSP(MAINMEMORYSIZE-1);

	// Assign the processor to the selected process
	OperatingSystem_Dispatch(selectedProcess);

	// Initial operation for Operating System
	Processor_SetPC(OS_address_base);

	OperatingSystem_PrintStatus();
}

// The LTS is responsible of the admission of new processes in the system.
// Initially, it creates a process from each program specified in the 
// 			command line and daemons programs
int OperatingSystem_LongTermScheduler() {
  
	int PID, numberOfSuccessfullyCreatedProcesses=0;

	switch (OperatingSystem_IsThereANewProgram()){
		case YES:
			do {
				int i = Heap_poll(arrivalTimeQueue, QUEUE_ARRIVAL, &numberOfProgramsInArrivalTimeQueue); // indexInProgramList

				PID=OperatingSystem_CreateProcess(i);
				switch (PID) {
					case NOFREEENTRY:
						// Shows error: "ERROR: There are not free entries in the process table for the program [%s]\n"
						ComputerSystem_DebugMessage(TIMED_MESSAGE, 50, ERROR, programList[i]->executableName);
						continue;
					
					case PROGRAMDOESNOTEXIST:
						// Shows error: "ERROR: Program [nameOfProgram] is not valid [--- it does not exist ---]\n"
						ComputerSystem_DebugMessage(TIMED_MESSAGE, 51, ERROR, programList[i]->executableName, "it does not exist");
						continue;
					
					case PROGRAMNOTVALID:
						// Shows error: "ERROR: Program [nameOfProgram] is not valid [--- invalid priority or size ---]\n"
						ComputerSystem_DebugMessage(TIMED_MESSAGE, 51, ERROR, programList[i]->executableName, "invalid priority or size");
						continue;
					
					case TOOBIGPROCESS:
						// Shows error: "ERROR: Program [nameOfProgram] is too big\n"
						ComputerSystem_DebugMessage(TIMED_MESSAGE, 52, ERROR, programList[i]->executableName);
						continue;
					
					case MEMORYFULL:
						// Shows error: "ERROR: A process could not be created from program [nameOfProgram] because an appropriate partition is not available\n"
						ComputerSystem_DebugMessage(TIMED_MESSAGE, 39, ERROR, programList[i]->executableName);
						continue;
						
					default:
						break;
				}

				numberOfSuccessfullyCreatedProcesses++;
				if (programList[i]->type==USERPROGRAM) {
					numberOfNotTerminatedUserProcesses++;
				}
				// Move process to the ready state
				OperatingSystem_MoveToTheREADYState(PID);

				// Prints the change from NEW to READY
				ComputerSystem_DebugMessage(TIMED_MESSAGE,53,SYSPROC,PID,programList[processTable[PID].programListIndex]->executableName,statesNames[0],statesNames[1]);

			} while (OperatingSystem_IsThereANewProgram() == YES);
			
			break;
		case NO:
			break;
		case EMPTYQUEUE:
			break;
	}

	// Return the number of succesfully created processes
	return numberOfSuccessfullyCreatedProcesses;
}

// This function creates a process from an executable program
int OperatingSystem_CreateProcess(int indexOfExecutableProgram) {

	int PID;
	int processSize;
	int loadingPhysicalAddress;
	int priority;
	FILE *programFile;
	PROGRAMS_DATA *executableProgram=programList[indexOfExecutableProgram];

	// Obtain a process ID
	PID=OperatingSystem_ObtainAnEntryInTheProcessTable();
	if (PID == NOFREEENTRY) { // MAXIMUM NUMBER OF PROGRAMS reached
		return NOFREEENTRY;
	}
	
	// Check if programFile exists
	programFile=fopen(executableProgram->executableName, "r");
	if (programFile == NULL) { // The program does not exist
		return PROGRAMDOESNOTEXIST;
	}

	// Obtain the memory requirements of the program
	processSize=OperatingSystem_ObtainProgramSize(programFile);
	if (processSize == PROGRAMNOTVALID) { // The program does not have processSize
		return PROGRAMNOTVALID;
	}

	// Obtain the priority for the process
	priority=OperatingSystem_ObtainPriority(programFile);
	if (priority == PROGRAMNOTVALID) { // The program does not have priority
		return PROGRAMNOTVALID;
	}
	
	// Process [PID - NAME] requests [processSize] memory positions\n
	ComputerSystem_DebugMessage(TIMED_MESSAGE,42,SYSMEM,PID, executableProgram->executableName, processSize);

	// Obtain enough memory space
 	int IDHole=OperatingSystem_ObtainMainMemory(processSize);
	switch (IDHole) {
		case TOOBIGPROCESS: return TOOBIGPROCESS;
		case MEMORYFULL: return MEMORYFULL;
		default: break;
	}
	loadingPhysicalAddress = partitionsAndHolesTable[IDHole].initAddress;

	// Load program in the allocated memory
	int result = OperatingSystem_LoadProgram(programFile, loadingPhysicalAddress, processSize);
	if (result == TOOBIGPROCESS) { // The memory requested is lower than the program size
		return TOOBIGPROCESS;
	}

	OperatingSystem_DivideHole(IDHole, PID, executableProgram->executableName, processSize);
	
	// PCB initialization
	OperatingSystem_PCBInitialization(PID, loadingPhysicalAddress, processSize, priority, indexOfExecutableProgram);

	OperatingSystem_ShowPartitionsAndHolesTable(messagesPartitions[1]);
	
	// Show message "Process [PID] created into the [new] state, from program [executableName]\n"
	ComputerSystem_DebugMessage(TIMED_MESSAGE,54,SYSPROC,PID, statesNames[0], executableProgram->executableName);
	
	return PID;
}


// Main memory is assigned in chunks. All chunks are the same size. A process
// always obtains the chunk whose position in memory is equal to the processor identifier
int OperatingSystem_ObtainMainMemory(int processSize) {
	int i;
	int sum_holes_size = 0;
	int lowest_valid_size = -1;
	int valid = -1;

	for (i = 0; i < PARTITIONSANDHOLESTABLEMAXSIZE; i++) {
		//"INITIAL ADDRESS: %d, SIZE: %d, PID: %d\n", partitionsAndHolesTable[i].initAddress, partitionsAndHolesTable[i].size, partitionsAndHolesTable[i].PID
		if (partitionsAndHolesTable[i].PID == HOLE) {
			sum_holes_size = sum_holes_size + partitionsAndHolesTable[i].size;
			if (partitionsAndHolesTable[i].size >= processSize) { // If its valid
				if (lowest_valid_size == -1 || partitionsAndHolesTable[i].size < lowest_valid_size) {
					lowest_valid_size = partitionsAndHolesTable[i].size;
					valid = i;
				}
			}
		}
	}

	if (lowest_valid_size != -1) {return valid;}

	// No hole found
	if (processSize > sum_holes_size) { // The program does not fit in main memory
		return TOOBIGPROCESS;
	} else { // Fits in main memory but the holes are separated so it does not fit
		return MEMORYFULL;
	}
}


// Assign initial values to all fields inside the PCB
void OperatingSystem_PCBInitialization(int PID, int initialPhysicalAddress, int processSize, int priority, int processPLIndex) {
	processTable[PID].busy=1;
	processTable[PID].initialPhysicalAddress=initialPhysicalAddress;
	processTable[PID].processSize=processSize;
	processTable[PID].copyOfSPRegister=initialPhysicalAddress+processSize;
	processTable[PID].state=NEW;
	processTable[PID].priority=priority;
	processTable[PID].programListIndex=processPLIndex;
	// Daemons run in protected mode and MMU use real address
	if (programList[processPLIndex]->type == DAEMONPROGRAM) { // DAEMON PROGRAM
		processTable[PID].copyOfPCRegister=initialPhysicalAddress;
		processTable[PID].copyOfPSWRegister= ((unsigned int) 1) << EXECUTION_MODE_BIT;
		processTable[PID].queueID = DAEMONSQUEUE;
	} 
	else { // USER PROGRAM
		processTable[PID].copyOfPCRegister=0;
		processTable[PID].copyOfPSWRegister=0;
		processTable[PID].queueID = USERPROCESSQUEUE;
	}
}


// Move a process to the READY state: it will be inserted, depending on its priority, in
// a queue of identifiers of READY processes
void OperatingSystem_MoveToTheREADYState(int PID) {

	int queueID = processTable[PID].queueID;
	
	if (Heap_add(PID, readyToRunQueue[queueID],QUEUE_PRIORITY ,&(numberOfReadyToRunProcesses[queueID]))>=0) {
		processTable[PID].state=READY;
	}
	// OperatingSystem_PrintReadyToRunQueue();
}


// The STS is responsible of deciding which process to execute when specific events occur.
// It uses processes priorities to make the decission. Given that the READY queue is ordered
// depending on processes priority, the STS just selects the process in front of the READY queue
int OperatingSystem_ShortTermScheduler() {
	
	int selectedProcess;

	selectedProcess=OperatingSystem_ExtractFromReadyToRun();
	
	return selectedProcess;
}


// Return PID of more priority process in the READY queue
int OperatingSystem_ExtractFromReadyToRun() {
  
	int selectedProcess=NOPROCESS;

	selectedProcess=Heap_poll(readyToRunQueue[USERPROCESSQUEUE],QUEUE_PRIORITY ,&(numberOfReadyToRunProcesses[USERPROCESSQUEUE]));
	if (selectedProcess == -1) {
		selectedProcess=Heap_poll(readyToRunQueue[DAEMONSQUEUE],QUEUE_PRIORITY ,&(numberOfReadyToRunProcesses[DAEMONSQUEUE]));
	}
	
	// Return most priority process or NOPROCESS if empty queue
	return selectedProcess; 
}


// Function that assigns the processor to a process
void OperatingSystem_Dispatch(int PID) {

	// The process identified by PID becomes the current executing process
	executingProcessID=PID;

	// Prints the change from READY to EXECUTING
	ComputerSystem_DebugMessage(TIMED_MESSAGE,53,SYSPROC,executingProcessID,programList[processTable[executingProcessID].programListIndex]->executableName,statesNames[1],statesNames[2]);
	
	// Change the process' state
	processTable[PID].state=EXECUTING;
	// Modify hardware registers with appropriate values for the process identified by PID
	OperatingSystem_RestoreContext(PID);
}


// Modify hardware registers with appropriate values for the process identified by PID
void OperatingSystem_RestoreContext(int PID) {
  
	// New values for the CPU registers are obtained from the PCB
	Processor_PushInSystemStack(processTable[PID].copyOfPCRegister);
	Processor_PushInSystemStack(processTable[PID].copyOfPSWRegister);
	Processor_SetRegisterSP(processTable[PID].copyOfSPRegister);

	// Set general registers
	Processor_SetAccumulator(processTable[PID].copyOfAccumulatorRegister);
	Processor_SetRegisterA(processTable[PID].copyOfRegisterA);
	Processor_SetRegisterB(processTable[PID].copyOfRegisterB);

	// Same thing for the MMU registers
	MMU_SetBase(processTable[PID].initialPhysicalAddress);
	MMU_SetLimit(processTable[PID].processSize);
}


// Function invoked when the executing process leaves the CPU 
void OperatingSystem_PreemptRunningProcess() {

	// Save in the process' PCB essential values stored in hardware registers and the system stack
	OperatingSystem_SaveContext(executingProcessID);
	// Prints the change from EXECUTING to READY
	ComputerSystem_DebugMessage(TIMED_MESSAGE,53,SYSPROC,executingProcessID,programList[processTable[executingProcessID].programListIndex]->executableName,statesNames[2],statesNames[1]);
	// Change the process' state
	OperatingSystem_MoveToTheREADYState(executingProcessID);
	// The processor is not assigned until the OS selects another process
	executingProcessID=NOPROCESS;
}


// Save in the process' PCB essential values stored in hardware registers and the system stack
void OperatingSystem_SaveContext(int PID) {
	
	// Load PSW saved for interrupt manager
	processTable[PID].copyOfPSWRegister=Processor_PopFromSystemStack(); // Flags
	
	// Load PC saved for interrupt manager
	processTable[PID].copyOfPCRegister=Processor_PopFromSystemStack(); // Next instruction to execute
	
	// Save RegisterSP 
	processTable[PID].copyOfSPRegister=Processor_GetRegisterSP(); // Stack pointer register

	// Save general registers
	processTable[PID].copyOfAccumulatorRegister = Processor_GetAccumulator();
	processTable[PID].copyOfRegisterA = Processor_GetRegisterA();
	processTable[PID].copyOfRegisterB = Processor_GetRegisterB();
}


// Exception management routine
void OperatingSystem_HandleException() {
  
	// Show message "Process [executingProcessID - executableName] has generated an exception and is terminating\n"
	//ComputerSystem_DebugMessage(TIMED_MESSAGE,71,INTERRUPT,executingProcessID,programList[processTable[executingProcessID].programListIndex]->executableName);
	
	// Show message "Process [executingProcessID - executableName] has caused an exception (ExceptionType) and is being terminated\n"
	ComputerSystem_DebugMessage(TIMED_MESSAGE,40,INTERRUPT,executingProcessID,programList[processTable[executingProcessID].programListIndex]->executableName, exceptionsNames[Processor_GetRegisterD()]);

	OperatingSystem_TerminateExecutingProcess();

	OperatingSystem_PrintStatus();
}

// All tasks regarding the removal of the executing process
void OperatingSystem_TerminateExecutingProcess() {

	processTable[executingProcessID].state=EXIT;
	// Prints the change from EXECUTING to EXIT
	ComputerSystem_DebugMessage(TIMED_MESSAGE,53,SYSPROC,executingProcessID,programList[processTable[executingProcessID].programListIndex]->executableName,statesNames[2],statesNames[4]);

	OperatingSystem_ReleaseMainMemory(executingProcessID);
	
	if (executingProcessID==sipID) {
		// finishing sipID, change PC to address of OS HALT instruction
		Processor_SetSSP(MAINMEMORYSIZE-1);
		Processor_PushInSystemStack(OS_address_base+1);
		Processor_PushInSystemStack(Processor_GetPSW());
		executingProcessID=NOPROCESS;
		ComputerSystem_DebugMessage(TIMED_MESSAGE,99,SHUTDOWN,"The system will shut down now...\n");
		return; // Don't dispatch any process
	}

	Processor_SetSSP(Processor_GetSSP()+2); // unstack PC and PSW stacked

	if (programList[processTable[executingProcessID].programListIndex]->type==USERPROGRAM) 
		// One more user process that has terminated
		numberOfNotTerminatedUserProcesses--;
	
	if (numberOfNotTerminatedUserProcesses==0 && OperatingSystem_IsThereANewProgram() == EMPTYQUEUE) {
		// Simulation must finish, telling sipID to finish
		OperatingSystem_ReadyToShutdown();
	}
	// Select the next process to execute (sipID if no more user processes)
	int selectedProcess=OperatingSystem_ShortTermScheduler();

	// Assign the processor to that process
	OperatingSystem_Dispatch(selectedProcess);
}

// System call management routine
void OperatingSystem_HandleSystemCall() {
  
	int systemCallID;

	// Register A contains the identifier of the issued system call
	systemCallID=Processor_GetRegisterC();
	
	switch (systemCallID) {
		case SYSCALL_END: // SYSCALL_END = 3
			// Show message: "Process [executingProcessID] has requested to terminate\n"
			ComputerSystem_DebugMessage(TIMED_MESSAGE,73,SYSPROC,executingProcessID,programList[processTable[executingProcessID].programListIndex]->executableName);
			OperatingSystem_TerminateExecutingProcess();
			OperatingSystem_PrintStatus();
			break;
		case SYSCALL_YIELD: { // SYSCALL_YIELD = 4
			int currentPID = executingProcessID;
			char currentName[MAXFILENAMELENGTH];
			strcpy(currentName, programList[processTable[currentPID].programListIndex]->executableName);

			int possibleNewPID = Heap_getFirst(readyToRunQueue[processTable[executingProcessID].queueID], numberOfReadyToRunProcesses[processTable[executingProcessID].queueID]);
			if (possibleNewPID != -1 && processTable[executingProcessID].priority == processTable[possibleNewPID].priority)			
			{ // If exists
				int selectedProcessPID = OperatingSystem_ShortTermScheduler();
				char selectedName[MAXFILENAMELENGTH];
				strcpy(selectedName, programList[processTable[selectedProcessPID].programListIndex]->executableName);

				// Show message: "Process [executingProcessID - exProcessName] will transfer the control of the processor to process [NewPID - NewName]\n"
				ComputerSystem_DebugMessage(TIMED_MESSAGE,55,SHORTTERMSCHEDULE,currentPID, currentName, selectedProcessPID, selectedName);

				OperatingSystem_PreemptRunningProcess(); // Saves the value to the PCB
			
				OperatingSystem_Dispatch(selectedProcessPID); // Locates the "new" process the executing state
				
				// Prints the status if it has changed the process
				OperatingSystem_PrintStatus();
			} else {
				// Show message: "Process [executingProcessID - exProcessName] cannot transfer the control of the processor to any process\n"
				ComputerSystem_DebugMessage(TIMED_MESSAGE,56,SHORTTERMSCHEDULE,currentPID, currentName);
			}
			break;
		}
		case SYSCALL_PRINTEXECPID: // SYSCALL_PRINTEXECPID = 5
			// Show message: "Process [executingProcessID] has the processor assigned\n"
			ComputerSystem_DebugMessage(TIMED_MESSAGE,72,SYSPROC,executingProcessID,programList[processTable[executingProcessID].programListIndex]->executableName,Processor_GetRegisterA(),Processor_GetRegisterB());
			break;
		case SYSCALL_SLEEP: {// SYSCALL_SLEEP = 7
			int regD = Processor_GetRegisterD();

			int delay;
			if (regD > 0) {
				delay = regD;
			} else {
				delay = abs(Processor_GetAccumulator());
			}

			processTable[executingProcessID].whenToWakeUp = delay + numberOfClockInterrupts + 1;

			OperatingSystem_BlockRunningProcess();

			// Select the next process to execute (sipID if no more user processes)
			int selectedProcess=OperatingSystem_ShortTermScheduler();

			// Assign the processor to that process
			OperatingSystem_Dispatch(selectedProcess);

			// Prints the status
			OperatingSystem_PrintStatus();
			
			break;
		}
		default: { // Else finish the process as it is not defined
			// Shows message: "41,Process [PID - executablename] has made an invalid system call (regD) and is being terminated\n"
			ComputerSystem_DebugMessage(TIMED_MESSAGE,41,INTERRUPT,executingProcessID,programList[processTable[executingProcessID].programListIndex]->executableName,systemCallID);
			
			OperatingSystem_TerminateExecutingProcess();

			OperatingSystem_PrintStatus();

			break;
		}
	}
}
	
//	Implement interrupt logic calling appropriate interrupt handle
void OperatingSystem_InterruptLogic(int entryPoint){
	switch (entryPoint){
		case SYSCALL_BIT: // SYSCALL_BIT=2
			OperatingSystem_HandleSystemCall();
			break;
		case EXCEPTION_BIT: // EXCEPTION_BIT=6
			OperatingSystem_HandleException();
			break;
		case CLOCKINT_BIT: // CLOCKINT_BIT=9
			OperatingSystem_HandleClockInterrupt();
			break;
	}
}

////////////////////////////////////

void OperatingSystem_PrintReadyToRunQueue() {
	
	ComputerSystem_DebugMessage(TIMED_MESSAGE,108,SHORTTERMSCHEDULE);
	int queueValue;
	int i;
	for (queueValue = 0; queueValue < NUMBEROFQUEUES; queueValue++) {

		ComputerSystem_DebugMessage(NO_TIMED_MESSAGE, 109, SHORTTERMSCHEDULE, queueNames[queueValue]);

		for (i = 0; i < numberOfReadyToRunProcesses[queueValue]; i++) {
			int PID = readyToRunQueue[queueValue][i].info;
			int priority = processTable[PID].priority;
			if (i == 0) {
				ComputerSystem_DebugMessage(NO_TIMED_MESSAGE, 110, SHORTTERMSCHEDULE, PID, priority);
			} else {
				ComputerSystem_DebugMessage(NO_TIMED_MESSAGE, 111, SHORTTERMSCHEDULE, PID, priority);
			}
		}

		ComputerSystem_DebugMessage(NO_TIMED_MESSAGE, 112, SHORTTERMSCHEDULE); // \n
	}

	// ComputerSystem_DebugMessage(TIMED_MESSAGE,103,SHORTTERMSCHEDULE);
	// int i;
	// for (i = 0; i < numberOfReadyToRunProcesses; i++) {
	// 	int PID = readyToRunQueue[i].info;
	// 	int priority = processTable[PID].priority;
	// 	int queueID = processTable[PID].queueID;
	// 	if (i == 0) {
	// 		ComputerSystem_DebugMessage(NO_TIMED_MESSAGE, 104, SHORTTERMSCHEDULE, PID, priority);
	// 	} else {
	// 		ComputerSystem_DebugMessage(NO_TIMED_MESSAGE, 105, SHORTTERMSCHEDULE, PID, priority);
	// 	}
    // }
	// if (i > 0)
	// 	ComputerSystem_DebugMessage(NO_TIMED_MESSAGE, 106, SHORTTERMSCHEDULE);
}

void OperatingSystem_HandleClockInterrupt()
{
	numberOfClockInterrupts++;
	ComputerSystem_DebugMessage(TIMED_MESSAGE, 57, INTERRUPT, numberOfClockInterrupts);
	int WokenUpProcesses, CreatedProcesses;
	WokenUpProcesses = OperatingSystem_CheckBlocked(); /* Revise sleeping queue */
	CreatedProcesses = OperatingSystem_LongTermScheduler(); /* Calls to the LTS */

	if (executingProcessID == sipID && numberOfNotTerminatedUserProcesses == 0 && OperatingSystem_IsThereANewProgram() == EMPTYQUEUE) { // sipID running and 0 processes created and empty queue
		// Simulation must finish, telling sipID to finish
		OperatingSystem_ReadyToShutdown();
	}

	if (WokenUpProcesses > 0 || CreatedProcesses > 0) {
		OperatingSystem_PrintStatus();
	}

	if (OperatingSystem_CheckChangeProcessWithMorePriority()) { // The process has changed
		OperatingSystem_PrintStatus();
	}
}

// Move a process to the BLOCK state: it will be inserted, depending on its priority, in
// a queue of identifiers of BLOCK processes
void OperatingSystem_MoveToTheBLOCKEDState(int PID) {
	if (Heap_add(PID, sleepingProcessesQueue ,QUEUE_WAKEUP ,&(numberOfSleepingProcesses))>=0) {
		processTable[PID].state=BLOCKED;
	}
}

int OperatingSystem_ExtractFromBlocked() {
	int selectedProcess=NOPROCESS;
	selectedProcess=Heap_poll(sleepingProcessesQueue,QUEUE_WAKEUP ,&(numberOfSleepingProcesses));
	
	// Return less wake up process or NOPROCESS if empty queue
	return selectedProcess; 
}

// Function invoked when the executing process leaves the CPU 
void OperatingSystem_BlockRunningProcess() {
	// Save in the process' PCB essential values stored in hardware registers and the system stack
	OperatingSystem_SaveContext(executingProcessID);
	// Prints the change from EXECUTING to BLOCKED
	ComputerSystem_DebugMessage(TIMED_MESSAGE,53,SYSPROC,executingProcessID,programList[processTable[executingProcessID].programListIndex]->executableName,statesNames[2],statesNames[3]);
	// Change the process' state
	OperatingSystem_MoveToTheBLOCKEDState(executingProcessID);
	// The processor is not assigned until the OS selects another process
	executingProcessID=NOPROCESS;
}

int OperatingSystem_CheckBlocked() {
	int WokenUpProcesses = 0;
	while (Heap_getFirst(sleepingProcessesQueue, numberOfSleepingProcesses) != -1 && processTable[Heap_getFirst(sleepingProcessesQueue, numberOfSleepingProcesses)].whenToWakeUp == numberOfClockInterrupts) {
		int unblokedPID = OperatingSystem_ExtractFromBlocked();
		
		// Prints the change from BLOCKED to READY
		ComputerSystem_DebugMessage(TIMED_MESSAGE,53,SYSPROC,unblokedPID,programList[processTable[unblokedPID].programListIndex]->executableName,statesNames[3],statesNames[1]);
	
		OperatingSystem_MoveToTheREADYState(unblokedPID);
		WokenUpProcesses++;
	} // Wakes up all the processes that have to wake up in each clock cycle
	return WokenUpProcesses;
}

int OperatingSystem_CheckPriority() {
	int selectedProcess;

	selectedProcess=Heap_getFirst(readyToRunQueue[USERPROCESSQUEUE], numberOfReadyToRunProcesses[USERPROCESSQUEUE]);
	if (selectedProcess != -1) {
		if (processTable[executingProcessID].queueID != processTable[selectedProcess].queueID) {
			return 1; // Needs to change it (As the selected process is in a more important queue)
		} else { // The processes are of the same type (compare priority (the more the less important))
			return processTable[executingProcessID].priority > processTable[selectedProcess].priority;
		}
	}
	selectedProcess=Heap_getFirst(readyToRunQueue[DAEMONSQUEUE], numberOfReadyToRunProcesses[DAEMONSQUEUE]);
	if (processTable[executingProcessID].queueID != processTable[selectedProcess].queueID) {
		return 0; // No needs to change it (As the selected process is in a less important queue)
	} else { // The processes are of the same type (compare priority (the more the less important))
		return processTable[executingProcessID].priority > processTable[selectedProcess].priority;
	}
}

int OperatingSystem_CheckChangeProcessWithMorePriority() {
	if (OperatingSystem_CheckPriority()) {
		int currentPID = executingProcessID;
		char currentName[MAXFILENAMELENGTH];
		strcpy(currentName, programList[processTable[currentPID].programListIndex]->executableName);

		int selectedProcessPID = OperatingSystem_ShortTermScheduler();
		char selectedName[MAXFILENAMELENGTH];
		strcpy(selectedName, programList[processTable[selectedProcessPID].programListIndex]->executableName);

		// Show message: "Process [executingProcessID – exProcessName] is thrown out of the processor by process [NewPID – NewName]\n"
		ComputerSystem_DebugMessage(TIMED_MESSAGE,58,SHORTTERMSCHEDULE,currentPID, currentName, selectedProcessPID, selectedName);

		OperatingSystem_PreemptRunningProcess(); // Saves the value to the PCB
	
		OperatingSystem_Dispatch(selectedProcessPID); // Locates the process the executing state

		return 1; // Changed
	}
	return 0; // No change
}

void OperatingSystem_DivideHole(int IDHole, int PID, char executableName[], int processSize) {
	OperatingSystem_ShowPartitionsAndHolesTable(messagesPartitions[0]);

	int initAddressHole = partitionsAndHolesTable[IDHole].initAddress;
	int sizeHole = partitionsAndHolesTable[IDHole].size;

	partitionsAndHolesTable[IDHole].PID = PID;
	partitionsAndHolesTable[IDHole].size = processSize;
	// Prints "Partition [IDHole: startAdress -> size] has been assigned to process [PID - ProcessName1]"
	ComputerSystem_DebugMessage(TIMED_MESSAGE,43,SYSMEM,IDHole, partitionsAndHolesTable[IDHole].initAddress, processSize, PID, executableName);

	if (sizeHole > processSize) {
		OperatingSystem_MovePartitionsToRightFrom(IDHole+1); // Starting from the next address of the hole
		partitionsAndHolesTable[IDHole + 1].initAddress = initAddressHole + processSize;
		partitionsAndHolesTable[IDHole + 1].size = sizeHole - processSize;
		partitionsAndHolesTable[IDHole + 1].PID = HOLE;
		// Prints "New hole [IDHOLE+1: 224 -> 12] has been created after assigning memory to process [1 - NomProgPid1]"
		ComputerSystem_DebugMessage(TIMED_MESSAGE,44,SYSMEM,IDHole+1, partitionsAndHolesTable[IDHole+1].initAddress, sizeHole - processSize, PID, executableName);
	} // Else the size must be equal to the hole (so nothing more)
}
//"INITIAL ADDRESS: %d, SIZE: %d, PID: %d\n", partitionsAndHolesTable[i].initAddress, partitionsAndHolesTable[i].size, partitionsAndHolesTable[i].PID

void OperatingSystem_MovePartitionsToRightFrom(int startIndex) {
	if (PARTITIONSANDHOLESTABLEMAXSIZE > numberOfPartitionsAndHoles) { // If the table is already full there is nothing we can do
		int i;
		for(i = numberOfPartitionsAndHoles; i > startIndex; i--) {
			partitionsAndHolesTable[i] = partitionsAndHolesTable[i - 1];
		}
		numberOfPartitionsAndHoles++;
	}
}

void OperatingSystem_MovePartitionsToLeftFrom(int removedIndex) {
	if (numberOfPartitionsAndHoles > 1) { // If the table has only 1 you cannot move nothing
		int i;
		for(i = removedIndex; i < numberOfPartitionsAndHoles - 1; i++) {
			partitionsAndHolesTable[i] = partitionsAndHolesTable[i + 1];
		}
		numberOfPartitionsAndHoles--;
	}
}

void OperatingSystem_ReleaseMainMemory(int PID) {
	int i;
	int idPositionPartitionOfProcessRemoved = -1;
	for (i = 0; i < numberOfPartitionsAndHoles; i++) { // Searches for the partition of the PID
		if (partitionsAndHolesTable[i].PID == PID) {
			idPositionPartitionOfProcessRemoved = i;
			break;
		}
	}

	if (idPositionPartitionOfProcessRemoved == -1) {
		// Never must happen if the PID as input is the executingPID
		return; // It may be changed in a future V5
	}

	OperatingSystem_ShowPartitionsAndHolesTable(messagesPartitions[2]);

	partitionsAndHolesTable[idPositionPartitionOfProcessRemoved].PID = HOLE;

 	// Prints: "Partition [IDPartition: Start-> size] used by process [PID - ProcessName] has been released"
	ComputerSystem_DebugMessage(TIMED_MESSAGE,45,SYSMEM,
		idPositionPartitionOfProcessRemoved,
		partitionsAndHolesTable[idPositionPartitionOfProcessRemoved].initAddress,
		partitionsAndHolesTable[idPositionPartitionOfProcessRemoved].size,
		PID,
		programList[processTable[PID].programListIndex]->executableName);

	int numberOfCoalescedHoles = OperatingSystem_CoalesceHoles(idPositionPartitionOfProcessRemoved);

	if (numberOfCoalescedHoles != 0) {
		// Prints: "Two or more holes has been coalesced\n"
		ComputerSystem_DebugMessage(TIMED_MESSAGE,144,SYSMEM);
	}



	OperatingSystem_ShowPartitionsAndHolesTable(messagesPartitions[3]);
}

int OperatingSystem_CoalesceHoles(int originPartitionHole) {
	int numberOfCoalescedHoles = 0;
	if (originPartitionHole < numberOfPartitionsAndHoles - 1) { // Check next
		if (partitionsAndHolesTable[originPartitionHole + 1].PID == HOLE) { // MERGE
			numberOfCoalescedHoles++;
			partitionsAndHolesTable[originPartitionHole].size = partitionsAndHolesTable[originPartitionHole].size + partitionsAndHolesTable[originPartitionHole + 1].size;

			OperatingSystem_MovePartitionsToLeftFrom(originPartitionHole + 1);
		}
	}
	if (originPartitionHole > 0) { // Check previous
		if (partitionsAndHolesTable[originPartitionHole - 1].PID == HOLE) { // MERGE
			numberOfCoalescedHoles++;
			partitionsAndHolesTable[originPartitionHole - 1].size = partitionsAndHolesTable[originPartitionHole - 1].size + partitionsAndHolesTable[originPartitionHole].size;

			OperatingSystem_MovePartitionsToLeftFrom(originPartitionHole);
		}
	}
	
	return numberOfCoalescedHoles;
}