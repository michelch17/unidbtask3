package se.michel.project.model;

public class StudyPeriodYear {
    private final String period;
    private final int year;

    public StudyPeriodYear(String period, int year) {
        this.period = period;
        this.year = year;
    }

    public String getPeriod() {
        return period;
    }

    public int getYear() {
        return year;
    }
}
