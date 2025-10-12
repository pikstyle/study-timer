# Configuration du Widget iOS

Tous les fichiers du widget ont été créés. Suivez ces étapes pour ajouter le Widget Extension à votre projet Xcode :

## Étape 1 : Ajouter le Widget Extension Target dans Xcode

1. Ouvrez le projet dans Xcode :
   ```bash
   open study-timer.xcodeproj
   ```

2. Dans Xcode, allez dans **File > New > Target...**

3. Sélectionnez **Widget Extension** et cliquez sur **Next**

4. Configurez le widget :
   - **Product Name** : `StudyTimerWidget`
   - **Bundle Identifier** : `com.jeune-sim.study-timer.StudyTimerWidget`
   - Décochez "Include Configuration Intent" (on n'en a pas besoin)
   - Cliquez sur **Finish**

5. Quand Xcode demande "Activate 'StudyTimerWidget' scheme?", cliquez sur **Cancel** ou **Activate** (peu importe)

6. **IMPORTANT** : Supprimez les fichiers générés automatiquement par Xcode :
   - `StudyTimerWidget/StudyTimerWidget.swift` (sera remplacé)
   - `StudyTimerWidget/AppIntent.swift` (non nécessaire)
   - `StudyTimerWidget/Assets.xcassets` (sera remplacé)

7. Ajoutez les fichiers créés au target :
   - Faites un **clic droit** sur le dossier `StudyTimerWidget` dans le navigateur de projet
   - Sélectionnez **Add Files to "study-timer"...**
   - Naviguez vers `/Users/simon/Documents/Dev/projects/study-timer/StudyTimerWidget/`
   - Sélectionnez tous les fichiers :
     - `StudyTimerWidget.swift`
     - `WidgetSharedModels.swift`
     - `Info.plist`
     - `Assets.xcassets` (dossier)
   - **Assurez-vous** que "Target Membership" inclut **StudyTimerWidget**
   - Cliquez sur **Add**

## Étape 2 : Configurer l'App Group

### 2.1 Pour l'Application Principale

1. Sélectionnez le projet `study-timer` dans le navigateur
2. Sélectionnez le target **study-timer** (l'app principale)
3. Allez dans l'onglet **Signing & Capabilities**
4. Cliquez sur **+ Capability**
5. Recherchez et ajoutez **App Groups**
6. Cliquez sur le **+** dans la section App Groups
7. Entrez : `group.com.jeune-sim.study-timer`
8. Cliquez sur **OK**

### 2.2 Pour le Widget Extension

1. Sélectionnez le target **StudyTimerWidget**
2. Allez dans l'onglet **Signing & Capabilities**
3. Cliquez sur **+ Capability**
4. Recherchez et ajoutez **App Groups**
5. **Cochez** le groupe existant : `group.com.jeune-sim.study-timer`

### 2.3 Vérifier le Team de Développement

1. Pour le target **study-timer** :
   - Onglet **Signing & Capabilities**
   - Team : M23F32HG62 (déjà configuré)

2. Pour le target **StudyTimerWidget** :
   - Onglet **Signing & Capabilities**
   - Sélectionnez le même Team : **M23F32HG62**

## Étape 3 : Build et Test

1. Sélectionnez le scheme **study-timer** (pas le widget)
2. Choisissez un simulateur iPhone (iPhone 15 recommandé)
3. Build et lancez l'app (⌘R)
4. Créez quelques sessions d'étude dans l'app
5. Retournez à l'écran d'accueil du simulateur
6. Appuyez longuement sur l'écran d'accueil jusqu'à ce que les apps tremblent
7. Cliquez sur le **+** en haut à gauche
8. Recherchez "study-timer" ou "Temps d'étude"
9. Choisissez une taille de widget (Small, Medium, ou Large)
10. Positionnez le widget sur l'écran d'accueil

## Étape 4 : Vérification

Le widget devrait maintenant afficher :
- L'icône du soleil avec "Aujourd'hui"
- Le temps total d'étude du jour
- Un pie chart avec les catégories (tailles Medium et Large)
- La liste des catégories avec leur temps respectif (taille Large)

## Tailles de Widget Disponibles

- **Small** : Temps total avec icône simple
- **Medium** : Temps total + mini pie chart + 2 catégories
- **Large** : Temps total + pie chart complet + toutes les catégories

## Dépannage

### Le widget ne charge pas les données

1. Vérifiez que l'App Group est bien configuré dans les deux targets
2. Assurez-vous que l'ID de l'App Group est le même partout :
   - `StudyRepository.swift` : ligne 35
   - `WidgetSharedModels.swift` : ligne 43
3. Nettoyez le build : **Product > Clean Build Folder** (⇧⌘K)
4. Rebuild le projet

### Le widget affiche "Aucune session"

1. Lancez l'app principale
2. Créez au moins une session d'étude
3. Retournez à l'écran d'accueil
4. Le widget se rafraîchira automatiquement dans les 15 minutes
5. Pour forcer le rafraîchissement : supprimez et réajoutez le widget

### Erreur de build

1. Vérifiez que tous les fichiers sont bien ajoutés au target **StudyTimerWidget**
2. Vérifiez que le Bundle Identifier du widget est : `com.jeune-sim.study-timer.StudyTimerWidget`
3. Assurez-vous que le Deployment Target du widget est le même que l'app (iOS 26.0)

## Prochaines Étapes

Vous pouvez personnaliser le widget :
- Modifier les couleurs dans `StudyTimerWidget.swift`
- Ajouter des tailles de widget supplémentaires
- Créer des widgets pour "Cette semaine" et "Ce mois"
- Ajouter des interactions (deeplinks vers l'app)

Bon courage ! 🚀
