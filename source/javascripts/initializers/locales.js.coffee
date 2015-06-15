angular.module("app").config ($translateProvider) ->
  $translateProvider.translations 'fr',
    SIGN_IN_WITH_GOOGLE: "Se connecter avec Google"
    ADD_PROJECTION: "Nouvelle projection"
    UPDATE_PROJECTION: "Modifier la projection"
    LABEL_ADD: "Détail"
    SPENDING_ADD: "Dépense"
    INCOME_ADD: "Revenu"
    CREATE: "Ajouter"
    CANCEL: "Annuler"
    UPDATE: "Modifier"
    DESTROY: "Supprimer"
    RECURRING: "Tout les mois"
    EVERY_DAY: "par jour"
    EVERY_MONTH: "par mois"
    ADD_SPENDING: "Ajouter une dépense"
    ADD_INCOME: "Ajouter un revenu"
    SETTINGS: "Modifier les options"
    DISCONNECT: "Se déconnecter"
    REMAINING: "reste"

  $translateProvider.preferredLanguage('fr')
