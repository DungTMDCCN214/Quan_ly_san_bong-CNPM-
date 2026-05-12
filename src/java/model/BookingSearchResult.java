package model;

import java.util.List;

/**
 * DTO dùng để hiển thị kết quả tìm kiếm đơn đặt sân.
 * Tổng hợp thông tin từ Bookings + Customers + Invoices + BookingDetails.
 */
public class BookingSearchResult {
    private int bookingId;
    private String bookingStatus;   // BOOKED, CANCELLED,...
    private String bookingDate;     // ngày tạo đơn

    // Thông tin khách hàng
    private String customerName;
    private String customerPhone;

    // Tổng tiền từ Invoices
    private int netAmount;
    private String invoiceStatus;   // PAID, UNPAID

    // Danh sách chi tiết (slot) để hiển thị tags
    private List<BookingDetailSlot> slots;

    // ─── Inner class gọn cho từng slot trong card ─────────────────────
    public static class BookingDetailSlot {
        private String courtName;
        private String slotStart;
        private String slotEnd;

        public BookingDetailSlot() {}
        public BookingDetailSlot(String courtName, String slotStart, String slotEnd) {
            this.courtName = courtName;
            this.slotStart = slotStart;
            this.slotEnd   = slotEnd;
        }

        public String getCourtName() { return courtName; }
        public void setCourtName(String courtName) { this.courtName = courtName; }
        public String getSlotStart() { return slotStart; }
        public void setSlotStart(String slotStart) { this.slotStart = slotStart; }
        public String getSlotEnd() { return slotEnd; }
        public void setSlotEnd(String slotEnd) { this.slotEnd = slotEnd; }
    }
    // ──────────────────────────────────────────────────────────────────

    public BookingSearchResult() {}

    public int getBookingId() { return bookingId; }
    public void setBookingId(int bookingId) { this.bookingId = bookingId; }

    public String getBookingStatus() { return bookingStatus; }
    public void setBookingStatus(String bookingStatus) { this.bookingStatus = bookingStatus; }

    public String getBookingDate() { return bookingDate; }
    public void setBookingDate(String bookingDate) { this.bookingDate = bookingDate; }

    public String getCustomerName() { return customerName; }
    public void setCustomerName(String customerName) { this.customerName = customerName; }

    public String getCustomerPhone() { return customerPhone; }
    public void setCustomerPhone(String customerPhone) { this.customerPhone = customerPhone; }

    public int getNetAmount() { return netAmount; }
    public void setNetAmount(int netAmount) { this.netAmount = netAmount; }

    public String getInvoiceStatus() { return invoiceStatus; }
    public void setInvoiceStatus(String invoiceStatus) { this.invoiceStatus = invoiceStatus; }

    public List<BookingDetailSlot> getSlots() { return slots; }
    public void setSlots(List<BookingDetailSlot> slots) { this.slots = slots; }
}
