<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%
    String currentPage = (String) request.getAttribute("currentPage");
    if (currentPage == null) currentPage = "";
%>
<style>
    .sidebar {
        width: 260px; min-height: 100vh;
        background: linear-gradient(180deg, #1a2332 0%, #243447 100%);
        display: flex; flex-direction: column;
        position: fixed; left: 0; top: 0; z-index: 100;
        box-shadow: 3px 0 15px rgba(0,0,0,0.2);
        transition: all 0.3s ease;
    }
    .sidebar-logo {
        padding: 22px 20px 18px; border-bottom: 1px solid rgba(255,255,255,0.08);
    }
    .sidebar-logo h2 { color: #4fc3f7; font-size: 1.1rem; font-weight: 700; margin: 0; }
    .sidebar-logo span { color: rgba(255,255,255,0.4); font-size: 0.72rem; }

    .sidebar-nav { padding: 14px 0; flex: 1; overflow-y: auto; }
    .nav-section {
        color: rgba(255,255,255,0.3); font-size: 0.68rem; font-weight: 700;
        letter-spacing: 1.2px; text-transform: uppercase; padding: 12px 20px 4px;
    }
    .nav-item {
        display: flex; align-items: center; gap: 11px;
        padding: 11px 20px; color: rgba(255,255,255,0.65);
        text-decoration: none; font-size: 0.9rem;
        transition: all 0.3s ease; cursor: pointer;
        border: none; background: none; width: 100%; text-align: left;
        border-left: 3px solid transparent;
    }
    .nav-item:hover { background: rgba(79,195,247,0.08); color: #81d4fa; }
    .nav-item.active { background: rgba(79,195,247,0.14); color: #4fc3f7; border-left-color: #4fc3f7; }
    .nav-item .ico { font-size: 1rem; width: 20px; text-align: center; }
    .nav-item .arrow { margin-left: auto; font-size: 0.68rem; transition: transform 0.3s ease; }
    .nav-item.open .arrow { transform: rotate(90deg); }

    /* Submenu */
    .submenu { overflow: hidden; max-height: 0; transition: max-height 0.35s ease; }
    .submenu.open { max-height: 200px; }
    .sub-item {
        display: flex; align-items: center; gap: 8px;
        padding: 9px 20px 9px 52px;
        color: rgba(255,255,255,0.5); text-decoration: none; font-size: 0.85rem;
        transition: all 0.3s ease; border-left: 3px solid transparent;
    }
    .sub-item:hover { color: #81d4fa; background: rgba(255,255,255,0.04); }
    .sub-item.active { color: #4fc3f7; font-weight: 600; border-left-color: #4fc3f7; }
    .sub-item::before { content: '•'; font-size: 0.55rem; color: rgba(255,255,255,0.25); }
    .sub-item.active::before { color: #4fc3f7; }
</style>

<div class="sidebar">
    <div class="sidebar-logo">
        <h2>⚽ Quản lý sân bóng đá</h2>
    </div>
    <nav class="sidebar-nav">
        
        <div class="nav-section">Quản lý</div>
        <a href="court" class="nav-item <%= "court".equals(currentPage) ? "active" : "" %>">
            <span class="ico">🏟️</span> Quản lý sân
        </a>
        <a href="customer" class="nav-item <%= "customer".equals(currentPage) ? "active" : "" %>">
            <span class="ico">👥</span> Khách hàng
        </a>
        <a href="service" class="nav-item <%= "service".equals(currentPage) ? "active" : "" %>">
            <span class="ico">📦</span> Dịch vụ
        </a>

        <%-- Đặt sân (submenu) --%>
        <% boolean isBooking = currentPage.startsWith("booking"); %>
        <div class="nav-item <%= isBooking ? "active open" : "" %>"
             onclick="toggleSub(this, 'sub-booking')">
            <span class="ico">📅</span> Đặt sân
            <span class="arrow">▶</span>
        </div>
        <div class="submenu <%= isBooking ? "open" : "" %>" id="sub-booking">
            <a href="booking?action=start"
               class="sub-item <%= "booking-new".equals(currentPage) ? "active" : "" %>">
                Đặt sân mới
            </a>
            <a href="searchBooking?action=search"
               class="sub-item <%= "booking-search".equals(currentPage) ? "active" : "" %>">
                Tìm kiếm đơn đặt
            </a>
        </div>

        <div class="nav-section">Tài chính</div>
        <a href="invoice" class="nav-item <%= "invoice".equals(currentPage) ? "active" : "" %>">
            <span class="ico">💰</span> Hóa đơn
        </a>
        <a href="revenue" class="nav-item <%= "revenue".equals(currentPage) ? "active" : "" %>">
            <span class="ico">📈</span> Doanh thu
        </a>
    </nav>
</div>

<script>
    function toggleSub(btn, id) {
        btn.classList.toggle('open');
        document.getElementById(id).classList.toggle('open');
    }
</script>