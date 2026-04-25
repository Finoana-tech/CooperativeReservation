<%@ page import="dao.ReservationDAO" %>
<%
    String idreserv = request.getParameter("id");
    ReservationDAO dao = new ReservationDAO();
    
    if (dao.supprimer(idreserv)) {
        response.sendRedirect("reservationList.jsp?success=suppression");
    } else {
        response.sendRedirect("reservationList.jsp?error=suppression");
    }
%>