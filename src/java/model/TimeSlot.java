package model;

public class TimeSlot {
    private int timeSlotId;
    private String startTime; // "08:00"
    private String endTime;   // "09:00"

    public TimeSlot() {}

    public TimeSlot(int timeSlotId, String startTime, String endTime) {
        this.timeSlotId = timeSlotId;
        this.startTime = startTime;
        this.endTime = endTime;
    }

    public int getTimeSlotId() { return timeSlotId; }
    public void setTimeSlotId(int timeSlotId) { this.timeSlotId = timeSlotId; }

    public String getStartTime() { return startTime; }
    public void setStartTime(String startTime) { this.startTime = startTime; }

    public String getEndTime() { return endTime; }
    public void setEndTime(String endTime) { this.endTime = endTime; }

    public String getLabel() { return startTime + " - " + endTime; }

    @Override
    public String toString() {
        return "TimeSlot{timeSlotId=" + timeSlotId + ", startTime='" + startTime + "', endTime='" + endTime + "'}";
    }
}
