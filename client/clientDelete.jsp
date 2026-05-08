<%@ page import="dao.ClientDAO" %>
<%
    String idcli = request.getParameter("id");
    ClientDAO dao = new ClientDAO();
    
    if (dao.supprimer(idreserv)) {
        response.sendRedirect("clientList.jsp?success=suppression");
    } else {
        response.sendRedirect("clientList.jsp?error=suppression");
    }
%>