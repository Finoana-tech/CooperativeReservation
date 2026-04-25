/**
 * scripts.js - Gestion globale des notifications et confirmations
 */

// 1. Fonction de CONFIRMATION avant suppression
function confirmerSuppression(id, detail, servletUrl) {
    Swal.fire({
        title: 'Êtes-vous sûr ?',
        text: "Vous allez supprimer : " + detail,
        icon: 'warning',
        showCancelButton: true,
        confirmButtonColor: '#1a3a5f',
        cancelButtonColor: '#dc3545',
        confirmButtonText: 'Oui, supprimer !',
        cancelButtonText: 'Annuler',
        reverseButtons: true
    }).then((result) => {
        if (result.isConfirmed) {
            window.location.href = servletUrl + "?action=delete&id=" + id;
        }
    });
}

// 2. Fonction pour afficher les alertes de SUCCÈS ou ERREUR (Automatique)
function verifierNotifications() {
    const urlParams = new URLSearchParams(window.location.search);
    if (urlParams.has('msg')) {
        const msg = urlParams.get('msg');
        let iconType = 'success';
        let titleText = 'Succès !';

        if (msg.toLowerCase().includes('erreur') || msg.toLowerCase().includes('impossible') || msg.toLowerCase().includes('dépasse')) {
            iconType = 'error';
            titleText = 'Attention';
        }

        Swal.fire({
            title: titleText,
            text: msg,
            icon: iconType,
            confirmButtonColor: '#1a3a5f'
        });
        window.history.replaceState({}, document.title, window.location.pathname);
    }
}

// 3. NOUVEAU : Validation du montant avant envoi au Servlet
// Cette fonction empêche le formulaire de partir si l'avance est trop élevée
function validerMontantAvance(event, prixUnitaire) {
    // On récupère les places (ex: "5,6,7") et on compte combien il y en a
    const placesInput = document.getElementById('place').value;
    const nbPlaces = placesInput.split(',').filter(p => p.trim() !== "").length;
    
    // On récupère le montant de l'avance saisie
    const avanceSaisie = parseInt(document.getElementById('montant_avance').value) || 0;
    const typePaiement = document.getElementById('payment').value;
    
    const totalFrais = prixUnitaire * nbPlaces;

    if (typePaiement === "avec avance" && avanceSaisie > totalFrais) {
        // On bloque l'envoi du formulaire
        event.preventDefault(); 

        Swal.fire({
            title: 'Montant invalide',
            text: 'L\'avance (' + avanceSaisie + ' Ar) ne peut pas être supérieure au total des frais (' + totalFrais + ' Ar pour ' + nbPlaces + ' place(s)).',
            icon: 'error',
            confirmButtonColor: '#1a3a5f'
        });
        return false;
    }
    return true;
}

document.addEventListener('DOMContentLoaded', verifierNotifications);