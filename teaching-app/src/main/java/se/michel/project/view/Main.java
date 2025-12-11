package se.michel.project.view;

import se.michel.project.controller.CostController;
import se.michel.project.model.TeachingCost;
import se.michel.project.model.ExerciseAllocationInfo;
import java.util.List;

import java.sql.SQLException;
import java.util.Scanner;

public class Main {
    public static void main(String[] args) {
        CostController controller = new CostController();
        Scanner scanner = new Scanner(System.in);

        while (true) {
            System.out.println("\n Menu:");
            System.out.println("1. Compute teaching cost for a course instance");
            System.out.println("2. Increase students by 100 and recompute cost");
            System.out.println("3. Allocate teaching activity");
            System.out.println("4. Deallocate teaching activity");
            System.out.println("5. Add Exercise activity and allocate a teacher");
            System.out.println("0. Exit");
            System.out.print("Enter your choice: ");

            String choice = scanner.nextLine();

            try {
                switch (choice) {
                    case "1" -> caseComputeCost(scanner, controller);
                    case "2" -> caseIncreaseStudents(scanner, controller);
                    case "3" -> caseAllocateTeacher(scanner, controller);
                    case "4" -> caseDeallocateTeacher(scanner, controller);
                    case "5" -> caseExerciseActivity(scanner, controller);

                    case "0" -> {
                        System.out.println("Exit");
                        return;
                    }
                    default -> System.out.println("Try again.");
                }
            } catch (Exception exception) {
                System.out.println("Error: " + exception.getMessage());
                exception.printStackTrace();
            }
        }
    }

    private static void caseComputeCost(Scanner scanner, CostController controller) throws SQLException {
        System.out.print("Enter course instance id: ");
        int id = Integer.parseInt(scanner.nextLine());

        TeachingCost cost = controller.computeTeachingCostCourseInstance(id);
        if (cost == null) {
            System.out.println("No course instance found with theid " + id);
            return;
        }

        System.out.println("\nTeaching cost for course instance " + id + ":");
        printCostTable(cost);
    }

    private static void caseIncreaseStudents(Scanner scanner, CostController controller) throws SQLException {
        System.out.print("Enter course instance id: ");
        int id = Integer.parseInt(scanner.nextLine());

        TeachingCost before = controller.computeTeachingCostCourseInstance(id);
        if (before == null) {
            System.out.println("No course instance found in current year with id " + id);
            return;
        }

        System.out.println("\nBEFORE increasing students:");
        printCostTable(before);

        TeachingCost after = controller.increaseStudentsComputeCost(id, 100);

        System.out.println("\nAFTER increasing students by 100:");
        printCostTable(after);
    }

    private static void caseAllocateTeacher(Scanner scanner, CostController controller) throws SQLException {
        System.out.print("Employee id: ");
        int empId = Integer.parseInt(scanner.nextLine());

        System.out.print("Course instance id: ");
        int ciId = Integer.parseInt(scanner.nextLine());

        System.out.print("Teaching activity id: ");
        int taId = Integer.parseInt(scanner.nextLine());

        System.out.print("Allocated hours: ");
        double hours = Double.parseDouble(scanner.nextLine());

        controller.allocateTeachingActivity(empId, ciId, taId, hours);
        System.out.println("Allocation created.");
    }

    private static void caseDeallocateTeacher(Scanner scanner, CostController controller) throws SQLException {
        System.out.print("Employee id: ");
        int empId = Integer.parseInt(scanner.nextLine());

        System.out.print("Course instance id: ");
        int ciId = Integer.parseInt(scanner.nextLine());

        System.out.print("Teaching activity id: ");
        int taId = Integer.parseInt(scanner.nextLine());

        controller.deallocateTeachingActivity(empId, ciId, taId);
        System.out.println("Allocation removed.");
    }

    private static void caseExerciseActivity(Scanner scanner, CostController controller) throws SQLException {
        System.out.print("Employee id: ");
        int empId = Integer.parseInt(scanner.nextLine());

        System.out.print("Course instance id: ");
        int ciId = Integer.parseInt(scanner.nextLine());

        System.out.print("Planned hours for Exercise: ");
        double planned = Double.parseDouble(scanner.nextLine());

        System.out.print("Allocated hours for Exercise: ");
        double allocated = Double.parseDouble(scanner.nextLine());

        System.out.print("Factor for Exercise: ");
        double factor = Double.parseDouble(scanner.nextLine());

        List<ExerciseAllocationInfo> ExcersisceInfo =
                controller.addExerciseActivityAndAllocate(empId, ciId, planned, allocated, factor);

        System.out.println("\nAllocations for teacher " + empId + " with activity Exercise:");
        System.out.println("Course_code | Course_instance | Period | Year | Teaching_activity | Allocated_hours");
        for (ExerciseAllocationInfo info : ExcersisceInfo) {
            System.out.printf("%s | %d | %s | %d | %s | %.2f\n", info.getCourseCode(), info.getCourseInstanceId(), info.getPeriod(), info.getYear(), info.getActivityName(), info.getAllocatedHours());
        }
    }

    private static void printCostTable(TeachingCost cost) {
        System.out.println("Course_Code | Course_Instance | Period | Planned_Cost_(KSEK) | Actual_Cost_(KSEK)");
        System.out.printf("%s | %d | %s | %.2f | %.2f\n", cost.getCourseCode(), cost.getCourseInstanceId(), cost.getPeriod(), cost.getPlannedCostKSEK(), cost.getActualCostKSEK());
    }
}
