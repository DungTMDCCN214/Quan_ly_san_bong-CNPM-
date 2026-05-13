package model;

/**
 * DTO dùng cho trang chi tiết đơn đặt sân.
 * Mỗi object = 1 dòng BookingDetails đã JOIN với Courts và TimeSlots.
 */
public class BookingDetailView {
    private int bookingDetailId;
    private String usageDate;
    private String detailStatus;    // BOOKED | PLAYING | DONE | CANCELLED
    private String courtName;
    private String courtType;
    private int pricePerHour;
    private String slotStart;       // "08:00"
    private String slotEnd;         // "09:00"

    public BookingDetailView() {}

    public int getBookingDetailId() { return bookingDetailId; }
    public void setBookingDetailId(int bookingDetailId) { this.bookingDetailId = bookingDetailId; }

    public String getUsageDate() { return usageDate; }
    public void setUsageDate(String usageDate) { this.usageDate = usageDate; }

    public String getDetailStatus() { return detailStatus; }
    public void setDetailStatus(String detailStatus) { this.detailStatus = detailStatus; }

    public String getCourtName() { return courtName; }
    public void setCourtName(String courtName) { this.courtName = courtName; }

    public String getCourtType() { return courtType; }
    public void setCourtType(String courtType) { this.courtType = courtType; }

    public int getPricePerHour() { return pricePerHour; }
    public void setPricePerHour(int pricePerHour) { this.pricePerHour = pricePerHour; }

    public String getSlotStart() { return slotStart; }
    public void setSlotStart(String slotStart) { this.slotStart = slotStart; }

    public String getSlotEnd() { return slotEnd; }
    public void setSlotEnd(String slotEnd) { this.slotEnd = slotEnd; }

    @Override
    public String toString() {
        return "BookingDetailView{id=" + bookingDetailId + ", court='" + courtName +
               "', slot=" + slotStart + "-" + slotEnd + ", status='" + detailStatus + "'}";
    }
}
