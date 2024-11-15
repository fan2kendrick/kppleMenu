/*
 *  SPDX-FileCopyrightText: 2020 Kpple <info.kpple@gmail.com>
 *  SPDX-FileCopyrightText: 2024 Christian Tallner <chrtall@gmx.de>
 *
 *  SPDX-License-Identifier: GPL-2.0-or-later
 */

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

import org.kde.plasma.plasmoid
import org.kde.plasma.components as PlasmaComponents
import org.kde.plasma.extras as PlasmaExtras
import org.kde.plasma.plasma5support as Plasma5Support
import org.kde.kirigami as Kirigami

PlasmoidItem {
    id: root
    toolTipSubText: i18n("Shortcuts for shutdown,reboot,logout, settings etc.")
    hideOnWindowDeactivate: true
    Plasmoid.icon: plasmoid.configuration.icon
    property bool fullRepHasFocus: false
    
    // define exec system ( call commands ) : by Uswitch applet! 
    Plasma5Support.DataSource {
        id: executable
        engine: "executable"
        connectedSources: []
        property var callbacks: ({})
        onNewData: {
            var stdout = data["stdout"]

            if (callbacks[sourceName] !== undefined) {
                callbacks[sourceName](stdout);
            }

            exited(sourceName, stdout)
            disconnectSource(sourceName) // exec finished
        }

        function exec(cmd, onNewDataCallback) {
            // Hide Applet Window after a cmd was selected by the user.
            root.expanded = false
            if (onNewDataCallback !== undefined){
                callbacks[cmd] = onNewDataCallback
            }
            connectSource(cmd)
        }
        signal exited(string sourceName, string stdout)
    }

    //define highlight
    PlasmaExtras.Highlight {
        id: delegateHighlight
        visible: false
    }

    onExpandedChanged : (expanded) => {
        if(expanded){
            // Always focus fullRep, when applet is expanded to enable keyboard navigation.
            root.fullRepHasFocus = true
        }else {
            // Deactivate Highlight and focus, when applet is minimized/hidden, else navigation state would persist.
            if (delegateHighlight.parent) {
                delegateHighlight.parent.focus = false
                delegateHighlight.parent = null
            }
            root.fullRepHasFocus = false
        }
    }

    fullRepresentation: Item {
        id: fullRep
        
        readonly property double iwSize: Kirigami.Units.gridUnit * 12.6 // item width
        readonly property double shSize: 1.1 // separator height
        
        // config var
        readonly property string aboutThisComputerCMD: plasmoid.configuration.aboutThisComputerSettings
        readonly property string systemPreferencesCMD: plasmoid.configuration.systemPreferencesSettings
        readonly property string appStoreCMD: plasmoid.configuration.appStoreSettings
        readonly property string forceQuitCMD: plasmoid.configuration.forceQuitSettings
        readonly property string sleepCMD: plasmoid.configuration.sleepSettings
        readonly property string restartCMD: plasmoid.configuration.restartSettings
        readonly property string shutDownCMD: plasmoid.configuration.shutDownSettings
        readonly property string lockScreenCMD: plasmoid.configuration.lockScreenSettings
        readonly property string logOutCMD: plasmoid.configuration.logOutSettings
        
        Layout.preferredWidth: iwSize
        Layout.preferredHeight: aboutThisComputerItem.height * 12

        focus: root.fullRepHasFocus
        Keys.onPressed: (event) => {
            switch (event.key) {
                // Enable Keyboard Navigation with Arrow Keys. Start at the bottom of list.
                case Qt.Key_Up:
                    logOutItem.forceActiveFocus()
                    break;
                // Enable Keyboard Navigation with Arrow Keys. Start at the top of list.
                case Qt.Key_Down:
                    aboutThisComputerItem.forceActiveFocus()
                    break;

            }
            // Use Lock Screen Shortcut displayed in UI. ⌘ is treated as Alt Key.
            if (event.key === Qt.Key_Q && (event.modifiers & Qt.ControlModifier) && (event.modifiers & Qt.AltModifier)){
                lockScreenItem.clicked()
            }
            // Use Log Out Shortcut display in UI. ⌘ is treated as Alt Key.
            if (event.key === Qt.Key_Q && (event.modifiers & Qt.ShiftModifier) && (event.modifiers & Qt.AltModifier)){
                logOutItem.clicked()
            }
        }

        ColumnLayout {
            id: columm
            anchors.fill: parent
            spacing: 2 // no spacing
            
            ListDelegate {
                id: aboutThisComputerItem
                highlight: delegateHighlight
                text: "A propos de cet ordinateur"
                onClicked: {
                    executable.exec(aboutThisComputerCMD); // cmd exec
                }
                activeFocusOnTab: true
                KeyNavigation.up: logOutItem
                KeyNavigation.down: systemPreferencesItem
            }

            MenuSeparator {
                id: s1
                padding: 0
                topPadding: 5
                bottomPadding: 5
                contentItem: Rectangle {
                    implicitWidth: iwSize
                    implicitHeight: shSize
                    color: "#1E000000"
                }
            }

            ListDelegate {
                id: systemPreferencesItem
                highlight: delegateHighlight
                width: parent
                text: "Paramètres système..."
                onClicked: {
                    executable.exec(systemPreferencesCMD); // cmd exec
                }
                activeFocusOnTab: true
                KeyNavigation.up: aboutThisComputerItem
                KeyNavigation.down: appStoreItem
            }

            ListDelegate {
                id: appStoreItem
                highlight: delegateHighlight
                text: "Store..."
                onClicked: {
                    executable.exec(appStoreCMD); // cmd exec
                }
                activeFocusOnTab: true
                KeyNavigation.up: systemPreferencesItem
                KeyNavigation.down: sleepItem
            }
            
            MenuSeparator {
                id: s3
                padding: 0
                topPadding: 5
                bottomPadding: 5
                contentItem: Rectangle {
                    implicitWidth: iwSize
                    implicitHeight: shSize
                    color: "#1E000000"
                }
            }

            ListDelegate {
                id: sleepItem
                highlight: delegateHighlight
                text: "Mettre en veille..."
                onClicked: {
                    executable.exec(sleepCMD); // cmd exec
                }
                activeFocusOnTab: true
                KeyNavigation.up: appStoreItem
                KeyNavigation.down: restartItem
            }

            ListDelegate {
                id: restartItem
                highlight: delegateHighlight
                text: "Redémarrer..."
                onClicked: {
                    executable.exec(restartCMD); // cmd exec
                }
                activeFocusOnTab: true
                KeyNavigation.up: sleepItem
                KeyNavigation.down: shutDownItem
            }

            ListDelegate {
                id: shutDownItem
                highlight: delegateHighlight
                text: "Arrêter..."
                onClicked: {
                    executable.exec(shutDownCMD); // cmd exec
                }
                activeFocusOnTab: true
                KeyNavigation.up: restartItem
                KeyNavigation.down: lockScreenItem
            }

            MenuSeparator {
                id: s4
                padding: 0
                topPadding: 5
                bottomPadding: 5
                contentItem: Rectangle {
                    implicitWidth: iwSize
                    implicitHeight: shSize
                    color: "#1E000000"
                }
            }

            ListDelegate {
                id: lockScreenItem
                highlight: delegateHighlight
                text: "Verouiller"
                onClicked: {
                    executable.exec(lockScreenCMD); // cmd exec
                }
                activeFocusOnTab: true
                KeyNavigation.up: shutDownItem
                KeyNavigation.down: logOutItem
            }

            ListDelegate {
                id: logOutItem
                highlight: delegateHighlight
                text: "Déconnexion"
                onClicked: {
                    executable.exec(logOutCMD); // cmd exec
                }
                activeFocusOnTab: true
                KeyNavigation.up: lockScreenItem
                KeyNavigation.down: aboutThisComputerItem
            }
        }
    }

} // end item


