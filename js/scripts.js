/*
 * scripts.js - Gestion globale des notifications et confirmations
 */
function confirmerSuppression(id, detail, servletUrl) {
    Swal.fire({
        title: 'Êtes-vous sûr ?',
        text: "Vous allez supprimer : " + detail,
        icon: 'warning',
        showCancelButton: true,
        confirmButtonColor: '#1a3a5f',
        cancelButtonColor: '#dc3545',
        confirmButtonText: 'Oui, supprimer',
        cancelButtonText: 'Annuler',
        reverseButtons: true
    }).then((result) => {
        if (result.isConfirmed) {
            window.location.href = servletUrl + "?action=delete&id=" + id;
        }
    });
}

function verifierNotifications() {
    const urlParams = new URLSearchParams(window.location.search);
    if (urlParams.has('msg')) {
        let msg = urlParams.get('msg');
        
        let iconType = 'success';
        let titleText = 'Succès !';

        const lowerMsg = msg.toLowerCase().trim();

        // Détection beaucoup plus large des erreurs
        if (lowerMsg.includes('existe déjà') || 
            lowerMsg.includes('déjà existant') || 
            lowerMsg.includes('déjà utilisé') ||
            lowerMsg.includes('erreur') || 
            lowerMsg.includes('impossible') || 
            lowerMsg.includes('invalide') ||
            lowerMsg.includes('échoué') ||
            lowerMsg.includes('dépasse') ||
            lowerMsg.startsWith('l\'id de voiture')) {   
            
            iconType = 'error';
            titleText = 'Attention';
        }

        Swal.fire({
            title: titleText,
            text: msg,
            icon: iconType,
            confirmButtonColor: '#1a3a5f',
            confirmButtonText: 'OK'
        });

        window.history.replaceState({}, document.title, window.location.pathname);
    }
}

function validerMontantAvance(event, prixUnitaire) {
    const placesInput = document.getElementById('place').value;
    const nbPlaces = placesInput.split(',').filter(p => p.trim() !== "").length;
   
    const avanceSaisie = parseInt(document.getElementById('montant_avance').value) || 0;
    const typePaiement = document.getElementById('payment').value;
   
    const totalFrais = prixUnitaire * nbPlaces;
    if (typePaiement === "avec avance" && avanceSaisie > totalFrais) {
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