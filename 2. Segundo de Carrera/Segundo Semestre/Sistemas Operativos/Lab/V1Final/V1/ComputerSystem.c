#include <string.h>
#include <ctype.h>
#include <stdio.h>
#include <stdlib.h>
#include "ComputerSystem.h"
#include "OperatingSystem.h"
#include "ComputerSystemBase.h"
#include "Processor.h"
#include "Messages.h"
#include "Asserts.h"
#include "Wrappers.h"

extern int COLOURED;
extern char *debugLevel;

// Functions prototypes
void ComputerSystem_PrintProgramList(int numberOfPrograms);

// Powers on of the Computer System.
void ComputerSystem_PowerOn(int argc, char *argv[], int paramIndex) {
	unsigned int i;
	// To remember the simulator sections to be message-debugged
	for (i=0; i< strlen(debugLevel);i++) {
	  if (isupper(debugLevel[i])){
		COLOURED = 1;
		debugLevel[i]=tolower(debugLevel[i]);
	  }
	}

	// Load debug messages
	int nm=0;
	nm=Messages_Load_Messages(nm,TEACHER_MESSAGES_FILE);
	if (nm<0) {
		ComputerSystem_DebugMessage(NO_TIMED_MESSAGE,64,SHUTDOWN,TEACHER_MESSAGES_FILE);
		exit(2);
	}
	nm=Messages_Load_Messages(nm,STUDENT_MESSAGES_FILE);

	// Prepare if necesary the assert system
	Asserts_LoadAsserts();

	ComputerSystem_DebugMessage(TIMED_MESSAGE, 99, POWERON, "STARTING simulation\n");
	// Obtain a list of programs in the command line
	int programsFromFilesBaseIndex = ComputerSystem_ObtainProgramList(argc, argv, paramIndex);

	ComputerSystem_PrintProgramList(programsFromFilesBaseIndex);

	// Request the OS to do the initial set of tasks. The last one will be
	// the processor allocation to the process with the highest priority
	OperatingSystem_Initialize(programsFromFilesBaseIndex);
	
	// Tell the processor to begin its instruction cycle 
	Processor_InstructionCycleLoop();
	
}

// Powers off the CS (the C program ends)
void ComputerSystem_PowerOff() {
	// Show message in red colour: "END of the simulation\n" 
	ComputerSystem_DebugMessage(TIMED_MESSAGE,99,SHUTDOWN,"END of the simulation\n"); 
	exit(0);
}

/////////////////////////////////////////////////////////
//  New functions below this line  //////////////////////

void ComputerSystem_PrintProgramList(int numberOfPrograms) {
	//ComputerSystem_DebugMessage(NO_TIMED_MESSAGE,103,INIT, numberOfPrograms);
	ComputerSystem_DebugMessage(TIMED_MESSAGE,101,INIT);
	
	// shows the user programs stored in the vector programsList
	int i;
	for (i = 1 ; i < numberOfPrograms; i++) {
		PROGRAMS_DATA *program = programList[i];
		ComputerSystem_DebugMessage(NO_TIMED_MESSAGE,102,INIT, program->executableName, program->arrivalTime);
		//ComputerSystem_DebugMessage(NO_TIMED_MESSAGE,100,INIT, program);
		//ComputerSystem_DebugMessage(NO_TIMED_MESSAGE,103,INIT, program->type);
		//ComputerSystem_DebugMessage(NO_TIMED_MESSAGE,103,INIT, program->arrivalTime);
		//ComputerSystem_DebugMessage(NO_TIMED_MESSAGE,100,INIT, program->executableName);
	}
}