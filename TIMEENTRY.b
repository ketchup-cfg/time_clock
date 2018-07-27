*** Time Entry Team Final Project
*** Authors: Iain Donkin
***          Justin Muniz
***          Trevor Pierce
***          Stephanie Etheridge
*** Date Last Edited: 05/01/17 by Trevor Pierce

    CRT@(-1)        ;* Clears the screen
    PROMPT ''       ;* Sets the PROMPT template to blank 
    MIDNIGHT = ICONV("23:59","MT")

    OPEN 'EMPLOYEES' TO F.EMPLOYEES ELSE          ;* This opens the employee data file and saves it to a variable
        ABORT 201, 'EMPLOYEES'          ;* This calls the error message 201 and says that the file could not be found
    END

    OPEN 'TIMESHEET' TO F.TIMESHEET ELSE          ;* This opens the employee time sheet file and saves it to a variable
        ABORT 201, 'TIMESHEET'          ;* This calls the error message 201 and says that the file could not be found
    END

    OPEN 'MANAGERSFILE' TO F.MANAGERSFILE ELSE    ;* This opens the employee managers file and saves it to a variable
        ABORT 201, 'MANAGERSFILE'       ;* This calls the error message 201 and says that the file could not be found
    END

23  GOSUB WELCOMENU ;* Calls a subroutine to display a menu for either clocking in/out or to go to management options
    GOSUB WELCOMECASE         ;* Calls a subroutine to handle a case system for the first menu selections

*******
HEADER:
*******
    CRT@(-1)        ;* Clears the screen
    PRINT "COOK MEDICAL SYSTEMS // DATE: " : OCONV (DATE(), "D2-") : " TIME: " : OCONV (TIME(), "MTH")
    PRINT STR("_",52)
    PRINT

    RETURN

**********
WELCOMENU:
**********
    GOSUB HEADER    ;* Calls a subroutine to set up and display a header that includes the time and date and also clears the screen

    PRINT "Hello! Please choose an selection from the menu below: "
    PRINT
    PRINT "1. Clock In/Out"
    PRINT "2. Management Options"
    PRINT "3. Exit Program"

    RETURN

************
WELCOMECASE:
************
    LOOP
        CRT@(55,4) : ; INPUT WelcomeSel,1         ;* This takes input from the user and stores it into a variable with a max length of 1 character
    UNTIL WelcomeSel = '3'    ;* If the user enters 3, the loop will end
        BEGIN CASE

        CASE WelcomeSel = '1'
            GOSUB CLOCKINOUT  ;* Calls a subroutine to allow an employees to clock in or out

        CASE WelcomeSel = '2'
            GOSUB LOGIN       ;* Calls a subroutine to ask the user for login credentials
68          GOSUB MANAGEMENU  ;* Calls a subroutine to display the manager main menu
            GOSUB MANAGECASE  ;* Calls a subroutine to handle a case system to deal with the manager main menu

        CASE 1      ;* This runs if the user enters an invalid value
            PRINT@(0,10) : "Invalid input. Please enter a number from 1 to 3. Thank you!"

        END CASE

    REPEAT

    CRT@(0,10) : @(-4) : "Exiting program." :     ;* This blocks displays a closing animation
    SLEEP 1
    PRINT "." :
    SLEEP 1
    PRINT "."

    STOP  ;* This stops the program

    RETURN

***********
CLOCKINOUT:
***********
79  GOSUB HEADER    ;* Calls a subroutine to set up and display a header that includes the time and date and also clears the screen

    PRINT "Please input your employee ID #: "
    PRINT
    PRINT "Enter Q to go back"

    CRT@(33,4) : ; INPUT ClockID        ;* Asks for a user to enter their employee ID

    IF OCONV(ClockID,"MCU") = "Q" THEN  ;* If the user enters q, then the program will go back to the last menu
        GOTO 23
    END

    IF NOT(ClockID MATCHES "3N") THEN   ;* This checks to make sure that the user has entered the employee ID # in the correct format
        PRINT
        EmployMatError = "Please enter a valid employee number (3 digits)"
        EmployMatLen = LEN(EmployMatError)
        PRINT EmployMatError :
        CRT@(EmployMatLen) : ; INPUT ANYTHING
        CRT@(-2)
        
        GOTO 79
    END

    READU R.EMPLOYEES FROM F.EMPLOYEES,ClockID THEN         ;* Reads the data from the record in the employee data file that matches the user-entered choice
        EmployeeName = R.EMPLOYEES<3>   ;* Gets the employee's name from the employee's EMPLOYEE data file record
        EmployeeDepartment = R.EMPLOYEES<5>       ;* Gets the employee's department from the employee's EMPLOYEE data file record
    END ELSE        ;* If the user does not enter a valid ID #, then this block will run
        CRT@(0,6) : @(-4) : "That is not a valid employee ID"
        CRT@(31,6) : ; INPUT ANYTHING
        CRT@(-2)
        
        GOTO 79
    END

    EmployeeDate = OCONV(DATE(),"D4/")  ;* Sets the clock-in/out date to the current date
    EmployeeTime = OCONV(TIME(),"MT")   ;* Sets the clock-in/out time to the current time
    ClockKey = ClockID : EmployeeDate   ;* Creates a key to open the TIMESHEET record for the employee for the current date

    READU R.TIMESHEET FROM F.TIMESHEET,ClockKey ELSE        ;* Reads the data from the record in the TIMESHEET data file for the current date and employee
        R.TIMESHEET = ''
    END

    IF R.TIMESHEET<3> = '' THEN         ;* This checks to see if the time-in field for the time sheet record is empty

        R.TIMESHEET<1> = ClockID        ;* This block fills out the employee's ID #, the current date, clock-in time, and employee department if the user has not clocked-in
        R.TIMESHEET<2> = EmployeeDate
        R.TIMESHEET<3> = EmployeeTime
        R.TIMESHEET<7> = EmployeeDepartment

        CRT@(0,6) : @(-4) :
        ClockMsg = "Hello, " : EmployeeName : ", you successfully clocked in on " : R.TIMESHEET<2> : " at " : R.TIMESHEET<3>
        ClockMsgLen = LEN(ClockMsg)
        PRINT ClockMsg

        WRITE R.TIMESHEET ON F.TIMESHEET,ClockKey ;* This saves all of the changed data to the TIMESHEET data record

        CRT@(ClockMsgLen,6) : ; INPUT ANYTHING
        CRT@(-2)
        
    END ELSE

        IF NOT(R.TIMESHEET<3> = '') AND R.TIMESHEET<4> = '' THEN      ;* This checks to see if the user has clocked-in, but not clocked-out
            R.TIMESHEET<4> = EmployeeTime         ;* This sets the employee's clock-out time to the current time

            CRT@(0,6) : @(-4) :
            ClockMsg = "Hello, " : EmployeeName : ", you successfully clocked out on " : R.TIMESHEET<2> : " at " : R.TIMESHEET<4>
            ClockMsgLen = LEN(ClockMsg)
            PRINT ClockMsg

            WRITE R.TIMESHEET ON F.TIMESHEET,ClockKey       ;* This saves all of the changed data to the TIMESHEET data record

            CRT@(ClockMsgLen,6) : ; INPUT ANYTHING
            CRT@(-2)
            
        END  ELSE

            IF NOT(R.TIMESHEET<3> = '') AND NOT(R.TIMESHEET<4> = '') THEN       ;* This checks to see if the user has clocked-in and out today

                CRT@(0,6) : @(-4) :
                ClockMsg = "Hello, " : EmployeeName : ", you have already clocked in and out today on " : R.TIMESHEET<2>
                ClockMsg2 = "Please contact your department manager if you feel that there has been an error"
                ClockMsgLen = LEN(ClockMsg2)
                PRINT ClockMsg
                PRINT ClockMsg2

                CRT@(ClockMsgLen,7) : ; INPUT ANYTHING
                CRT@(-2)
                
            END
        END
    END

    GOTO 23

    RETURN

******
LOGIN:
******
    FailedLogins = 0
    AttemptsRem = 3

    LOOP
        GOSUB HEADER          ;* Calls a subroutine to set up and display a header that includes the time and date and also clears the screen

        PRINT "Please enter your username: "
        PRINT@(0,7) : "Enter Q to go back"

        CRT@(28,4) : ; INPUT UserName   ;* Ask the user to enter their username

        IF OCONV(UserName,"MCU") = "Q" THEN       ;* If the user enters q, then the program will end
            GOTO 23
        END

        ECHO OFF    ;* This turns off the mirroring of a user's text entry to mask the user's password as they enter it

        PRINT@(0,5) : "Please enter your password: "
        CRT@(28,5) : ; INPUT Password   ;* Ask the user to enter their password

        ECHO ON     ;* This turns the text mirroring back on after the user enters their password

        IF OCONV(Password,"MCU") = "Q" THEN       ;* If the user enters q, then the program ends
            GOTO 23
        END

        CRT@(0,7) : @(-4)     ;* This clears the "Press Q" message

        IF FailedLogins >= 3 THEN       ;* This IF statement will check if the user has failed to provide valid login credentials three times, If so, this block will run
            PRINT "Too many failed login attempts. The program will now end. Please try again later."
            PRINT "Exiting program." :
            SLEEP 1
            PRINT "." :
            SLEEP 1
            PRINT "."
            STOP    ;* This ends the program
        END

    UNTIL ( UserName = 'Elisa42' AND Password = 'Password1' ) OR ( UserName = 'Billy24' AND Password = 'Password2' ) OR ( UserName = 'Zach43' AND Password = 'Password3' )          ;* This checks to see if the proper login credentials have been provided
        ErrorLogin = "Your username and/or password is incorrect. " : AttemptsRem : " login attempts remaining"         ;* This message describes the error to the user and displays how many login attempts are remaining
        ErrorLoginLen = LEN(ErrorLogin)
        PRINT ErrorLogin
        CRT@(ErrorLoginLen,8) : ; INPUT ANYTHING
        CRT@(-2)
        FailedLogins += 1     ;* This adds one to the failed login count
        AttemptsRem -= 1      ;* This subtracts one to the attempts remaining count

    REPEAT


    RETURN

***********
MANAGEMENU:
***********
    GOSUB HEADER    ;* Calls a subroutine to set up and display a header that includes the time and date and also clears the screen

    PRINT "Hello! Please choose an selection from the menu below: "
    PRINT
    PRINT "1. View Employee Information"
    PRINT "2. Logout"

    RETURN

***********
MANAGECASE:
***********
    LOOP
        CRT@(55,4) : ; INPUT ManageMenuSel,1      ;* This takes input from the user and stores it into a variable with a max length of 1 character

    UNTIL ManageMenuSel = '2' ;* If the user enters 2, the loop will end
        BEGIN CASE

        CASE ManageMenuSel = '1'
180         GOSUB TIMEREVIEW  ;* Calls a subroutine to calculate the time worked for the department
            GOSUB GETEMPLOYEES          ;* Calls a subroutine to lock the system to a department relating the manager logged on
            GOSUB PAINTLISTSCREEN       ;* Calls a subroutine to display labels for the list of the employees
            GOSUB PAINTLISTDATA         ;* Calls a subroutine to display the employee names and ID #'s
            GOSUB GETEMPLOYID ;* Calls a subroutine to ask the manager for an employee's ID #, then goes on to show and edit time sheets

        CASE 1      ;* This runs if the user enters an invalid value
            PRINT@(0,9) : "Invalid input. Please enter a number from 1 to 2. Thank you!"

        END CASE

    REPEAT

    UserName = ''   ;* This blocks resets the user's user name and password and returns them to the first menu
    Password = ''
    GOTO 23

    RETURN

***********
TIMEREVIEW:
***********
    BEGIN CASE

    CASE UserName = "Elisa42"
        EXECUTE 'SELECT TIMESHEET WITH 7 = Accounting'

    CASE UserName = "Billy24"
        EXECUTE 'SELECT TIMESHEET WITH 7 = Administration'

    CASE UserName = "Zach43"
        EXECUTE 'SELECT TIMESHEET WITH 7 = Facilities'

    CASE 1
        PRINT "You do not have permission to view employee information for this system"
        INPUT ANYTHING
        GOTO 68

    END CASE

    OPEN 'TIMESHEET' TO F.TIMESHEET ELSE          ;* This opens the TIMESHEET file with the records matching the department
        STOP 201, 'TIMESHEET'
    END

    TotalHours = 0

    LOOP
        READNEXT ID ELSE EXIT ;* This goes through each matching time sheet record
        READ R.TIMESHEET FROM F.TIMESHEET,ID ELSE
            R.TIMESHEET = ''
        END

        T1 = ICONV(R.TIMESHEET<3>,"MT") ;* This gets the clock-in time for an employee and converts it to a value that the program can use for math functions
        T2 = ICONV(R.TIMESHEET<4>,"MT") ;* This gets the clock-out time for an employee and converts it to a value that the program can use for math functions
        Dif = T2 - T1         ;* This subtracts the clock-out time from the clock-in time to get the total time worked for a day
        TotalHours = TotalHours + Dif   ;* This keeps a running total of the Dif values for every record
    REPEAT

    TotalHours = OCONV(TotalHours,"MT") ;* This converts the time to a HH:MM format
    TotalHoursLen = LEN(TotalHours)
    Colon = INDEX(TotalHours,":",1)
    Hours = TotalHours[1,Colon-1]       ;* This extracts the hours from TotalHours
    Minutes = TotalHours[Colon+1,TotalHoursLen]   ;* This extracts the minutes from TotalHours

    IF Minutes[1,1] = "0" THEN          ;* This checks to see if Minutes is below 10 so that we do not display something like "03 minutes" later
        Minutes = Minutes[2,2]
    END

    RETURN

*************
GETEMPLOYEES:
*************
    BEGIN CASE

    CASE UserName = 'Elisa42'
        READU R.MANAGERSFILE FROM F.MANAGERSFILE,2 ELSE     ;* This reads the data from the record in the managers data file from the second record
            R.MANAGERSFILE = ''
        END
        EXECUTE 'SELECT EMPLOYEES WITH 5 = Accounting'
        DepartmentLock = 'Accounting'

    CASE UserName = 'Billy24'
        READU R.MANAGERSFILE FROM F.MANAGERSFILE,1 ELSE     ;* This reads the data from the record in the managers data file from the second record
            R.MANAGERSFILE = ''
        END
        EXECUTE 'SELECT EMPLOYEES WITH 5 = Administration'
        DepartmentLock = 'Administration'

    CASE UserName = 'Zach43'
        READU R.MANAGERSFILE FROM F.MANAGERSFILE,3 ELSE     ;* This reads the data from the record in the managers data file from the second record
            R.MANAGERSFILE = ''
        END
        EXECUTE 'SELECT EMPLOYEES WITH 5 = Facilities'
        DepartmentLock = 'Facilities'

    CASE 1
        GOSUB PAINTLISTSCREEN
        PRINT "You do not have permission to view employee information for this system"
        INPUT ANYTHING
        GOTO 68

    END CASE

    ManagerFirst = R.MANAGERSFILE<1>    ;* This gets the user's first name
    Manager = ManagerFirst[1,1] : "." : R.MANAGERSFILE<2>   ;* This shortens the user's first name to one letter, then adds a period and their last name to the value

    RETURN

****************
PAINTLISTSCREEN:
****************
    GOSUB HEADER    ;* Calls a subroutine to set up and display a header that includes the time and data and also clears the screen

    PRINT "First Name" "L#25" : "Last Name" "L#25" : "Employee ID" "L#25"
    PRINT STR("_",75)

    RETURN

**************
PAINTLISTDATA:
**************

    OPEN 'EMPLOYEES' TO F.EMPLOYEES ELSE
        STOP 201, 'EMPLOYEES'
    END

    LOOP
        READNEXT ID ELSE EXIT
        READU R.EMPLOYEES FROM F.EMPLOYEES,ID ELSE
            R.EMPLOYEES = ''
        END
        PRINT R.EMPLOYEES<3> "L#25" : R.EMPLOYEES<2> "L#25" : R.EMPLOYEES<1> "L#25"

    REPEAT

    RETURN

************
GETEMPLOYID:
************
    PRINT
    PRINT
    PRINT "The " : OCONV(DepartmentLock,"MCL") : " department has worked " : Hours : " hours and " : Minutes : " minutes this week"         ;* This displays the number of hours and minutes worked for the department
    PRINT
    PRINT "Enter Employee ID Number: "
    PRINT
    PRINT "Enter Q to go back"

    PRINT@(-10) : @(-10) : @(-10) : @(26) : ; INPUT EmployKey         ;* Asks the user to enter an employee's ID # and save the entry as a variable

    IF OCONV(EmployKey,"MCU") = "Q" THEN          ;* If the user enters Q, then the program will take them back to the previous menu
        GOTO 68
    END

    IF NOT(EmployKey MATCHES "3N") THEN ;* This checks to make sure that the user has entered the employee ID # in the correct format
        PRINT
        EmployMatError = "Please enter a valid employee number (3 digits)"
        EmployMatLen = LEN(EmployMatError)
        PRINT EmployMatError :
        CRT@(EmployMatLen) : ; INPUT ANYTHING
        CRT@(-2)
        GOTO 180
    END

    READU R.EMPLOYEES FROM F.EMPLOYEES,EmployKey ELSE       ;* Reads the data from the record in the employee data file that matches the user-entered choice
        PRINT       ;* If the record does not exist
        EmployMatError = "There is no employee matching this ID #"
        EmployMatLen = LEN(EmployMatError)
        PRINT EmployMatError :
        CRT@(EmployMatLen) : ; INPUT ANYTHING
        CRT@(-2)
        GOTO 180
    END


    IF NOT(R.EMPLOYEES<5> = DepartmentLock) THEN  ;* This checks to see if the user has permission to view information about this employee
        PRINT
        EmployPerError = "You do not have permission to view information for employees outside of your department. Thank you!"
        EmployPerLen = LEN(EmployPerError)
        PRINT EmployPerError :
        CRT@(EmployPerLen) : ; INPUT ANYTHING
        CRT@(-2)
        GOTO 180
    END

    LOOP
261     GOSUB PAINTEMPLSCREEN ;* Calls a subroutine to display labels for the employee data
        GOSUB PAINTEMPLDATA   ;* Calls a subroutine to display the employee data

        PRINT "Open timesheet for this employee? (Y/N)" : ; INPUT OpenTime,1    ;* This takes input from the user and stores it into a variable with a max length of 1 character
    UNTIL OCONV(OpenTime,"MCU") = 'N'   ;* If the user enters n, the loop will end

        IF OCONV(OpenTime,"MCU") = 'Y' THEN       ;* If the user enters y, the subroutine on the line below will be called
            GOSUB TIMESHEET   ;* Calls a subroutine to display the employee's timesheet file
        END

    REPEAT

    GOTO 68         ;* This takes the user back to the previous menu

    RETURN

****************
PAINTEMPLSCREEN:
****************
    GOSUB HEADER

    PRINT "ID" "L#7" : "First Name" "L#12" : "Middle Initial" "L#16" : "Last Name" "L#11" : "Department" "L#15" : "Manager" "L#12"
    PRINT STR("_",73)

    RETURN

**************
PAINTEMPLDATA:
**************
    PRINT R.EMPLOYEES<1> "L#7" : R.EMPLOYEES<3> "L#12" : R.EMPLOYEES<4> "L#16" : R.EMPLOYEES<2> "L#11" : R.EMPLOYEES<5> "L#15" : Manager "L#12"
    PRINT

    RETURN

**********
TIMESHEET:
**********
    LOOP
        GOSUB HEADER          ;* Calls a subroutine to set up and display a header that includes the time and date and also clears the screen

        PRINT "What date would you like to view? (enter the date in a MM/DD/YYYY format) " : ; INPUT DateKey  ;* Asks the user to enter in the desired time sheet date in the proper format

        TimeSheetKey = EmployKey : DateKey        ;* This merges the employee ID # with the date to create the composite key needed for the TIMESHEET file

        READU R.TIMESHEET FROM F.TIMESHEET,TimeSheetKey ELSE          ;* Reads the data from the record in the timesheet data file that matches the user-entered choice
            KeyNotFound = "This record does not exist"      ;* This checks to see if the record exists
            KeyNotLen = LEN(KeyNotFound)
            PRINT KeyNotFound :
            CRT@(KeyNotLen) : ; INPUT ANYTHING
            CRT@(-2)
            GOTO 261
        END

        PRINT "Clock-in: " : R.TIMESHEET<3>
        PRINT "Clock-out: " : R.TIMESHEET<4>

        R.TIMESHEET<5> = R.MANAGERSFILE<4>        ;* This sets the Reviewed By field in the time sheet record to the manager's name
        R.TIMESHEET<6> = TIMEDATE()     ;* This sets the Reviewed On field in the time sheet record to the current date and time
        PRINT "Time sheet has been reviwed by " : R.TIMESHEET<5>      ;* This prints confirmation that the employee time sheet has been reviewed by a manager
        PRINT "Time sheet has been reviewed on " : R.TIMESHEET<6>     ;* This prints confirmation that the employee time sheet has been reviewed on the current date and at the current time
        WRITE R.TIMESHEET ON F.TIMESHEET,TimeSheetKey       ;* This saves the changed data to the time sheet record

        PRINT
        PRINT "Edit timesheet for this employee? (Y/N)" : ; INPUT EditTime,1    ;* This takes input from the user and stores it into a variable with a max length of 1 character

    UNTIL OCONV(EditTime,"MCU") = 'N'   ;* If the user enters n, the loop will end

        IF OCONV(EditTime,"MCU") = 'Y' THEN       ;* If the user enters y, the subroutine on the line below will be called
            GOSUB EDITTIME    ;* Calls a subroutine to allow the manager to edit the employee's timesheet file
        END

    REPEAT

    GOTO 68         ;* This takes the user back to the previous menu

    RETURN

*********
EDITTIME:
*********
    GOSUB HEADER    ;* Calls a subroutine to set up and display a header that includes the time and date and also clear the screen

    READU R.TIMESHEET FROM F.TIMESHEET,TimeSheetKey ELSE    ;* Reads the data from the record in the timesheet data file that matches the user-entered choice
        R.TIMESHEET = ''
    END

1   CRT@(0,5) : @(-4) : "New time-in: (please use the HH:MM format): " : ; INPUT NTimeIn  ;* Asks the user to enter a new clock-in time for the employee, plus clears the data entered if this line ever runs again

    IF NOT(NTimeIn MATCHES "2N':'2N") THEN        ;* This checks to see if the user has entered a time that matches the HH:MM format
        PRINT "Invalid input. Please enter a time in the HH:MM format"
        GOTO 1      ;* This will tell the program to go to the line that asks for the user to input a new time-in
    END

    IF ICONV(NTimeIn,"MT") > MIDNIGHT THEN
        PRINT "Invalid time input. Please enter a time between 00:00 and 23:59"
        GOTO 1
    END
    
2   CRT@(0,6) : @(-4) : "New time-out (please use the HH:MM format): " : ; INPUT NTimeOut ;* Asks the user to enter a new clock-out time for the employee, plus clears the data entered if this line ever runs again

    IF NOT(NTimeOut MATCHES "2N':'2N") THEN       ;* This checks to see if the user has entered a time that matches the HH:MM format
        PRINT "Invalid input. Please enter a time in the HH:MM format"
        GOTO 2      ;* This will tell the program to go to the line that asks for the user to input a new time-out
    END

    IF ICONV(NTimeOut,"MT") > MIDNIGHT THEN
        PRINT "Invalid time input. Please enter a time between 00:00 and 23:59"
        GOTO 2
    END

    CRT@(0,7) : @(-4)

    R.TIMESHEET<3> = NTimeIn  ;* This changes the value of the clock-in attribute for the employee
    R.TIMESHEET<4> = NTimeOut ;* The changes the value of the clock-out attribute for the employee

    PRINT
    PRINT "New time-in: " : R.TIMESHEET<3>        ;* This prints the new clock-in time to show that the change was successful
    PRINT "New time-out: " : R.TIMESHEET<4>       ;* This prints the new clock-out time to show that the change was successful

    WRITE R.TIMESHEET ON F.TIMESHEET,TimeSheetKey ;* This saves the changes to the timesheet data file
    PRINT
    EditMsg = "The time sheet for " : EmployKey : " has been successfully edited for " : DateKey
    EditLen = LEN(EditMsg)
    PRINT EditMsg :
    CRT@(EditLen) : ; INPUT ANYTHING    ;* If the user presses Enter, the program will proceed to the next line
    CRT@(-2)
    
    GOTO 180        ;* This takes the user back to the employee list

    RETURN




