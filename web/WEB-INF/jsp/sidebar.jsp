<%@page contentType="text/html" pageEncoding="UTF-8"%>
<style>
    .sidebar {
        width: 260px;
        background: linear-gradient(135deg, #0f2027 0%, #203a43 50%, #2c5364 100%);
        min-height: 100vh;
        position: fixed;
        top: 0;
        left: 0;
        padding-top: 20px;
        color: white;
        box-shadow: 4px 0 15px rgba(0,0,0,0.1);
        z-index: 1000;
    }
    .sidebar-logo {
        text-align: center;
        font-weight: 800;
        font-size: 1.5rem;
        margin-bottom: 30px;
        color: #38ef7d;
        letter-spacing: 1px;
    }
    .nav-link-custom {
        color: rgba(255,255,255,0.8);
        padding: 12px 20px;
        margin: 5px 15px;
        border-radius: 12px;
        transition: all 0.3s ease;
        font-weight: 500;
        display: block;
        text-decoration: none;
    }
    .nav-link-custom:hover, .nav-link-custom.active {
        background: rgba(255,255,255,0.15);
        color: white;
        transform: translateX(5px);
    }
    .nav-link-custom i {
        width: 25px;
    }
</style>

<div class="sidebar">
    <div class="sidebar-logo">
        Quản lý sân bóng
    </div>
    
    <a href="${pageContext.request.contextPath}/admin/dashboard" 
       class="nav-link-custom ${active == 'dashboard' ? 'active' : ''}">
         Tổng quan
    </a>
    
    <a href="${pageContext.request.contextPath}/court" 
       class="nav-link-custom ${active == 'court' ? 'active' : ''}">
         Quản lý Sân
    </a>
    
    <a href="${pageContext.request.contextPath}/customer" 
       class="nav-link-custom ${active == 'customer' ? 'active' : ''}">
         Quản lý khách hàng
    </a>
</div>