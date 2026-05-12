package model;

import java.sql.Date;

public class BookingDetail {
    private int bookingDetailId;
    private Date usageDate;
    private String status;
    private int timeSlotId;
    private int courtId;
    private int bookingId;

    // Các trường phụ (join từ Courts và TimeSlots – dùng để hiển thị)
    private String courtName;
    private String courtType;
    private double pricePerHour; // Đổi sang double để khớp với Court
    private String slotStart;
    private String slotEnd;

    public BookingDetail() {}

    public BookingDetail(int bookingDetailId, Date usageDate, String status,
                         int timeSlotId, int courtId, int bookingId) {
        this.bookingDetailId = bookingDetailId;
        this.usageDate = usageDate;
        this.status = status;
        this.timeSlotId = timeSlotId;
        this.courtId = courtId;
        this.bookingId = bookingId;
    }

    public int getBookingDetailId() { return bookingDetailId; }
    public void setBookingDetailId(int bookingDetailId) { this.bookingDetailId = bookingDetailId; }

    public Date getUsageDate() { return usageDate; }
    public void setUsageDate(Date usageDate) { this.usageDate = usageDate; }

    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }

    public int getTimeSlotId() { return timeSlotId; }
    public void setTimeSlotId(int timeSlotId) { this.timeSlotId = timeSlotId; }

    public int getCourtId() { return courtId; }
    public void setCourtId(int courtId) { this.courtId = courtId; }

    public int getBookingId() { return bookingId; }
    public void setBookingId(int bookingId) { this.bookingId = bookingId; }

    public String getCourtName() { return courtName; }
    public void setCourtName(String courtName) { this.courtName = courtName; }

    public String getCourtType() { return courtType; }
    public void setCourtType(String courtType) { this.courtType = courtType; }

    public double getPricePerHour() { return pricePerHour; } // Đổi kiểu trả về sang double
    public void setPricePerHour(double pricePerHour) { this.pricePerHour = pricePerHour; } // Đổi tham số sang double

    public String getSlotStart() { return slotStart; }
    public void setSlotStart(String slotStart) { this.slotStart = slotStart; }

    public String getSlotEnd() { return slotEnd; }
    public void setSlotEnd(String slotEnd) { this.slotEnd = slotEnd; }

    @Override
    public String toString() {
        return "BookingDetail{bookingDetailId=" + bookingDetailId + ", usageDate=" + usageDate +
               ", courtId=" + courtId + ", timeSlotId=" + timeSlotId + ", status='" + status + "'}";
    }
}