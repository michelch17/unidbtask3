Note: The folder teaching-app and the file teaching-app.zip contain the same project.
Insert SQL scripts: create_unidatabase.sql & insert_unidatabase.sql

Before running the program, you must update your database credentials:

Open: 
src/main/java/se/michel/project/integration/DatabaseConnection.java

Modify the following fields to match your database setup:
DATABASE NAME
USERNAME 
PASSWORD

=======================================================================================
RUNNING THE PROGRAM:

1. Open a terminal and navigate into the directory:
   cd teaching-app
2. Run the program with Maven:
   mvn exec:java -Dexec.mainClass="se.michel.project.view.Main"

=======================================================================================
PROGAM MENU:

When the program starts, you will see the following menu:

  Menu: 
  1. Compute teaching cost for a course instance 
  2. Increase students by 100 and recompute cost 
  3. Allocate teaching activity 
  4. Deallocate teaching activity 
  5. Add exercise activity and allocate a teacher 
  0. Exit 
  Enter your choice: 

=======================================================================================
Task Instructions:

Task 1: Compute teaching cost 
  You may choose course instance ID: 1, 2, or 3. 
  
Task 2: Increase students and recompute cost 
  You may choose course instance ID: 1, 2, or 3.

Task 3: Allocate a teaching activity 
  Each employee can be allocated to an activity.
    Example: 
      EMPLOYEE ID = 5 
      COURSE INSTANCE ID = 2 
      TEACHING ACTIVITY ID = 1

    Example to trigger the error:
      EMPLOYEE ID = 10 
      COURSE INSTANCE ID = 6 
      TEACHING ACTIVITY ID = 1
      
    OBS! Course instance 4, 5, and 6 are inserted solely to trigger this exception.

Task 4: Deallocate a teaching activity 
  Choose any employee that is already allocated to an activity. 
    Example: 
      EMPLOYEE ID = 5 
      COURSE INSTANCE ID = 1 
      TEACHING ACTIVITY ID = 1

Task 5: Add an exercise activity 
Exercise activity can be added to course instance ID: 1, 2, or 3, and any employee can be allocated.
	
	
