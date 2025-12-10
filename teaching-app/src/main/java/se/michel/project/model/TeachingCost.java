package se.michel.project.model;

public class TeachingCost {
    private final String courseCode;
    private final int courseInstanceId;
    private final String period;
    private final double plannedCostKSEK;
    private final double actualCostKSEK;

    public TeachingCost(String courseCode, int courseInstanceId, String period, double plannedCostKSEK, double actualCostKSEK) {
        this.courseCode = courseCode;
        this.courseInstanceId = courseInstanceId;
        this.period = period;
        this.plannedCostKSEK = plannedCostKSEK;
        this.actualCostKSEK = actualCostKSEK;
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

    public double getPlannedCostKSEK() { 
        return plannedCostKSEK; 
    }

    public double getActualCostKSEK() { 
        return actualCostKSEK; 
    }
}
