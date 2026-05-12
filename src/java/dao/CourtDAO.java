/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package dao;

/**
 *
 * @author Admin
 */
import java.sql.*;
import java.util.*;
import model.Court;

import java.sql.DriverManager;

public class CourtDAO {

    Connection connection;
    
    public CourtDAO() {
        try {
            String url = "jdbc:sqlserver://localhost;databaseName=QLy_san_bong;encrypt=true;trustServerCertificate=true";
            String user = "sa";
            String pass = "123456";

            Class.forName("com.microsoft.sqlserver.jdbc.SQLServerDriver");
            connection = DriverManager.getConnection(url, user, pass);

        } catch (Exception e) {
            e.printStackTrace(); 
        }
    }
    
    // GET ALL
    public List<Court> getAllCourts() {
        List<Court> list = new ArrayList<>();
        String sql = "SELECT * FROM Courts";

        try (PreparedStatement ps = connection.prepareStatement(sql); 
                ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                Court c = new Court(
                        rs.getInt("courtId"),
                        rs.getString("name"),
                        rs.getString("type"),           // Thêm type
                        rs.getDouble("pricePerHour"),
                        rs.getString("status"),
                        rs.getString("description"),
                        rs.getTimestamp("createdAt")    // Thêm created_at
                );
                list.add(c);
            }
        } catch(Exception e){
            e.printStackTrace();
        }
        return list;
    }
    
    // INSERT
    public void insertCourt(Court c){
        String sql = "INSERT INTO Courts(name, type, pricePerHour, status, description, createdAt) VALUES(?, ?, ?, ?, ?, GETDATE())";

        try(PreparedStatement ps = connection.prepareStatement(sql)){
            ps.setString(1, c.getName());
            ps.setString(2, c.getType());              // Thêm type
            ps.setDouble(3, c.getPrice_per_hour());
            ps.setString(4, c.getStatus());
            ps.setString(5, c.getDescription());
            // created_at sẽ tự động lấy GETDATE() từ SQL Server

            int rows = ps.executeUpdate();
            System.out.println("INSERT ROWS = " + rows);

        } catch(Exception e){
            e.printStackTrace();
        }
    }
    
    // DELETE
    public void deleteCourt(int id){
        String sql = "DELETE FROM Courts WHERE courtId = ?";
        
        try(PreparedStatement ps = connection.prepareStatement(sql)){
            ps.setInt(1, id);
            ps.executeUpdate();
        } catch(Exception e){
            e.printStackTrace();
        }
    }
    
    // GET BY ID
    public Court getCourtById(int id){
        String sql = "SELECT * FROM Courts WHERE courtId = ?";
        try(PreparedStatement ps = connection.prepareStatement(sql)){
            ps.setInt(1, id);
            ResultSet rs = ps.executeQuery();
            
            if(rs.next()){
                return new Court(
                        rs.getInt("courtId"),
                        rs.getString("name"),
                        rs.getString("type"),           // Thêm type
                        rs.getDouble("pricePerHour"),
                        rs.getString("status"),
                        rs.getString("description"),
                        rs.getTimestamp("createdAt")    // Thêm created_at
                );
            }
        } catch(SQLException e){
            e.printStackTrace();
        }
        return null;
    }
    
    // UPDATE
    public void updateCourt(Court c){
        String sql = "UPDATE Courts SET name=?, type=?, pricePerHour=?, status=?, description=? WHERE courtId=?";
        
        try(PreparedStatement ps = connection.prepareStatement(sql)){
            ps.setString(1, c.getName());
            ps.setString(2, c.getType());              // Thêm type
            ps.setDouble(3, c.getPrice_per_hour());
            ps.setString(4, c.getStatus());
            ps.setString(5, c.getDescription());
            ps.setInt(6, c.getCourt_id());
            
            ps.executeUpdate();
        } catch(Exception e){
            e.printStackTrace();
        }
    }
}