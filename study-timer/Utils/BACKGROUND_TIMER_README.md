# Configuration Timer en Arrière-plan

## Permissions nécessaires dans Info.plist

Ajoutez ces clés à votre `Info.plist` :

```xml
<!-- Permissions pour les notifications -->
<key>NSUserNotificationPermissionRequestDisplayName</key>
<string>Study Timer souhaite vous envoyer des notifications pour vous informer de votre progression d'étude</string>

<!-- Background modes pour l'actualisation en arrière-plan -->
<key>UIBackgroundModes</key>
<array>
    <string>background-app-refresh</string>
    <string>background-processing</string>
</array>

<!-- Description de l'utilisation des notifications -->
<key>NSUserNotificationAlertStyle</key>
<string>alert</string>
```

## Fonctionnalités du Timer en Arrière-plan

### 🎯 **Persistance complète**
- Le timer continue même si l'app est complètement fermée
- Calcul précis du temps écoulé basé sur la date/heure de démarrage
- Restauration automatique de l'état au redémarrage de l'app

### 📱 **Notifications intelligentes**
- Notification à 5 minutes : "Vous étudiez depuis 5 minutes ! 📚"
- Notification à 15 minutes : "Excellent ! 15 minutes d'étude accomplie ! 🎯"
- Notification à 30 minutes : "Bravo ! 30 minutes d'étude continue ! 🏆"
- Notification à 1 heure : "Incroyable ! 1 heure d'étude ! Pensez à faire une pause 😊"

### 🔄 **Synchronisation automatique**
- Détection automatique quand l'app revient au premier plan
- Calcul du temps réel basé sur l'heure système
- Mise à jour instantanée de l'interface utilisateur

### 💾 **Sauvegarde robuste**
- Utilisation de UserDefaults pour la persistance
- Sauvegarde périodique de l'état du timer
- Protection contre la perte de données lors de fermetures inattendues

## Architecture technique

### BackgroundTimerService
- **Singleton** qui gère la persistance du timer
- **UserDefaults** pour stocker l'état (date de début, secondes initiales, état)
- **UNUserNotificationCenter** pour les notifications
- **Calculs temporels précis** basés sur Date()

### TimerViewModel
- **Restauration automatique** de l'état au démarrage
- **Observers du cycle de vie** de l'app (background, foreground, terminate)
- **Synchronisation** entre le timer UI et le service arrière-plan
- **Timer local** pour l'interface utilisateur fluide

### Gestion du cycle de vie
1. **App active** : Timer local + mise à jour du service arrière-plan
2. **App en arrière-plan** : Service arrière-plan seul
3. **App fermée** : Persistance dans UserDefaults + notifications programmées
4. **App rouverte** : Restauration + synchronisation + redémarrage timer local

## Utilisation

1. **Démarrer** : `startTimer()` démarre le timer local ET le service arrière-plan
2. **Continuer** : Fermer l'app, le timer continue
3. **Reprendre** : Ouvrir l'app, synchronisation automatique
4. **Arrêter** : `stopTimer()` nettoie tout (timer + service + notifications)