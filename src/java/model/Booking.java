package model;

import java.sql.Date;

public class Booking {
    private int bookingId;
    private int customerId;
    private int managerId;
    private String status;
    private Date bookingDate;
    private double depositAmount;

    public Booking() {}

    public Booking(int bookingId, int customerId, int managerId, String status, Date bookingDate, double depositAmount) {
        this.bookingId = bookingId;
        this.customerId = customerId;
        this.managerId = managerId;
        this.status = status;
        this.bookingDate = bookingDate;
        this.depositAmount = depositAmount;
    }

    public int getBookingId() { return bookingId; }
    public void setBookingId(int bookingId) { this.bookingId = bookingId; }

    public int getCustomerId() { return customerId; }
    public void setCustomerId(int customerId) { this.customerId = customerId; }

    public int getManagerId() { return managerId; }
    public void setManagerId(int managerId) { this.managerId = managerId; }

    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }

    public Date getBookingDate() { return bookingDate; }
    public void setBookingDate(Date bookingDate) { this.bookingDate = bookingDate; }

    public double getDepositAmount() { return depositAmount; }
    public void setDepositAmount(double depositAmount) { this.depositAmount = depositAmount; }

    @Override
    public String toString() {
        return "Booking{bookingId=" + bookingId + ", customerId=" + customerId +
               ", managerId=" + managerId + ", status='" + status + "', bookingDate=" + bookingDate + 
               ", depositAmount=" + depositAmount + "}";
    }
}
