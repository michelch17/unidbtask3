package se.michel.project.model;

public class ExerciseAllocationInfo {
    private final String courseCode;
    private final int courseInstanceId;
    private final String period;
    private final int year;
    private final String activityName;
    private final int employeeId;
    private final double allocatedHours;

    public ExerciseAllocationInfo(String courseCode, int courseInstanceId, String period, int year, String activityName, int employeeId, double allocatedHours) {
        this.courseCode = courseCode;
        this.courseInstanceId = courseInstanceId;
        this.period = period;
        this.year = year;
        this.activityName = activityName;
        this.employeeId = employeeId;
        this.allocatedHours = allocatedHours;
    }

    public String getCourseCode() { 
        return courseCode; 
    }

    public int getCourseInstanceId() { 
        return courseInstanceId; 
    }

    public String getPeriod() { 
        return period; 
    }

    public int getYear() { 
        return year; 

    }

    public String getActivityName() { 
        return activityName; 
    }
    
    public int getEmployeeId() { 
        return employeeId; 
    }

    public double getAllocatedHours() { 
        return allocatedHours; 
    }
}
