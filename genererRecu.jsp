<%@ page language="java" contentType="application/pdf; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.io.*, java.util.*, java.sql.*, java.text.*, com.itextpdf.text.*, com.itextpdf.text.pdf.*, com.itextpdf.text.pdf.draw.*, dao.*, model.*" %>
<%
    String idreserv = request.getParameter("idreserv");
    
    if (idreserv != null) {
        ReservationDAO dao = new ReservationDAO();
        Reservation r = dao.getById(idreserv);
        
        if (r != null) {
            //  Configuration de la réponse
            response.setContentType("application/pdf");
            response.setHeader("Content-Disposition", "attachment; filename=recu_" + idreserv + ".pdf");

            try {
                //  Création du document
                Document document = new Document(PageSize.A5);
                PdfWriter.getInstance(document, response.getOutputStream());
                document.open();
                
                //  Polices
                Font titleFont = new Font(Font.FontFamily.HELVETICA, 16, Font.BOLD, new BaseColor(26, 58, 95));
                Font subtitleFont = new Font(Font.FontFamily.HELVETICA, 12, Font.BOLD);
                Font normalFont = new Font(Font.FontFamily.HELVETICA, 10, Font.NORMAL);
                Font boldFont = new Font(Font.FontFamily.HELVETICA, 10, Font.BOLD);
                
                //  En-tête
                Paragraph title = new Paragraph("COOPÉRATIVE DE TRANSPORT", titleFont);
                title.setAlignment(Element.ALIGN_CENTER);
                document.add(title);
                
                Paragraph subtitle = new Paragraph("REÇU DE RÉSERVATION", subtitleFont);
                subtitle.setAlignment(Element.ALIGN_CENTER);
                document.add(subtitle);
                
                document.add(new Paragraph(" ")); // Espacement
                LineSeparator ls = new LineSeparator();
                ls.setLineColor(new BaseColor(200, 200, 200));
                document.add(new Chunk(ls));
                document.add(new Paragraph(" "));

                //  Récupération des données liées
                Client client = new ClientDAO().getById(r.getIdcli());
                Voiture voiture = new VoitureDAO().getById(r.getIdvoit());
                SimpleDateFormat sdf = new SimpleDateFormat("dd/MM/yyyy", Locale.FRENCH);
                SimpleDateFormat sdfTime = new SimpleDateFormat("dd/MM/yyyy HH:mm", Locale.FRENCH);

                //  Informations principales
                PdfPTable tableInfo = new PdfPTable(2);
                tableInfo.setWidthPercentage(100);
                tableInfo.setBorderWidth(0);

                tableInfo.addCell(new PdfPCell(new Phrase("Reçu N° : " + r.getIdreserv(), boldFont)));
                tableInfo.addCell(new PdfPCell(new Phrase("Date : " + sdfTime.format(r.getDateReserv()), normalFont)));
                
                // Supprimer les bordures des cellules de info
                for(PdfPCell cell : tableInfo.getRow(0).getCells()) { cell.setBorder(Rectangle.NO_BORDER); }
                document.add(tableInfo);
                
                document.add(new Paragraph(" "));
                document.add(new Paragraph("CLIENT : " + (client != null ? client.getNom().toUpperCase() : "N/A"), boldFont));
                document.add(new Paragraph("CONTACT : " + (client != null ? client.getNumtel() : "N/A"), normalFont));
                document.add(new Paragraph("DATE DU VOYAGE : " + sdf.format(r.getDateVoyage()), boldFont));
                
                document.add(new Paragraph(" "));

                PdfPTable tableDetails = new PdfPTable(2);
                tableDetails.setWidthPercentage(100);
                tableDetails.setSpacingBefore(10f);

                // En-têtes du tableau
                PdfPCell h1 = new PdfPCell(new Phrase("DESCRIPTION", boldFont));
                h1.setBackgroundColor(BaseColor.LIGHT_GRAY);
                tableDetails.addCell(h1);
                
                PdfPCell h2 = new PdfPCell(new Phrase("MONTANT (Ar)", boldFont));
                h2.setBackgroundColor(BaseColor.LIGHT_GRAY);
                h2.setHorizontalAlignment(Element.ALIGN_RIGHT);
                tableDetails.addCell(h2);

                // Contenu
                tableDetails.addCell(new Phrase("Voiture " + r.getIdvoit() + " - Place N° " + r.getPlace(), normalFont));
                tableDetails.addCell(new Phrase(String.format("%,d", voiture.getFrais()), normalFont)).setHorizontalAlignment(Element.ALIGN_RIGHT);

                tableDetails.addCell(new Phrase("MODE DE PAIEMENT : " + r.getPayment().toUpperCase(), normalFont));
                tableDetails.addCell(new Phrase("-", normalFont)).setHorizontalAlignment(Element.ALIGN_RIGHT);

                // Calculs
                int total = voiture.getFrais();
                int avance = r.getMontantAvance();
                int reste = total - avance;

                PdfPCell cellAvanceLabel = new PdfPCell(new Phrase("MONTANT PAYÉ (AVANCE)", boldFont));
                cellAvanceLabel.setHorizontalAlignment(Element.ALIGN_RIGHT);
                tableDetails.addCell(cellAvanceLabel);
                tableDetails.addCell(new Phrase(String.format("%,d", avance), boldFont)).setHorizontalAlignment(Element.ALIGN_RIGHT);

                PdfPCell cellResteLabel = new PdfPCell(new Phrase("RESTE À PAYER", boldFont));
                cellResteLabel.setHorizontalAlignment(Element.ALIGN_RIGHT);
                tableDetails.addCell(cellResteLabel);
                
                PdfPCell cellResteVal = new PdfPCell(new Phrase(String.format("%,d", reste), boldFont));
                cellResteVal.setHorizontalAlignment(Element.ALIGN_RIGHT);
                if(reste > 0) cellResteVal.setBackgroundColor(new BaseColor(255, 240, 240));
                tableDetails.addCell(cellResteVal);

                document.add(tableDetails);

                document.add(new Paragraph(" "));
                document.add(new Paragraph(" "));
                Paragraph footer = new Paragraph("BON VOYAGE AVEC NOTRE COOPÉRATIVE !", new Font(Font.FontFamily.HELVETICA, 9, Font.ITALIC));
                footer.setAlignment(Element.ALIGN_CENTER);
                document.add(footer);

                document.close();
                out.clear(); 
                out = pageContext.pushBody();
            } catch (Exception e) {
                e.printStackTrace();
            }
        }
    } else {
        response.sendRedirect("reservation/reservationList.jsp");
    }
%>