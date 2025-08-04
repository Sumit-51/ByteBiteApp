import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

ApplicationWindow {
    id: window
    visible: true
    width: 390
    height: 844
    title: "ByteBite - Food Delivery"

    // Global properties for navigation compatibility
    property alias stackView: stackView
    property alias pageLoader: pageLoader

    // Scale factor for responsive design
    property real dp: Math.min(width / 375, height / 812)

    // Global navigation functions for backward compatibility
    function navigateTo(page) {
        console.log("🚀 Navigating to:", page)
        stackView.push(page)
    }

    function navigateBack() {
        if (stackView.depth > 1) {
            stackView.pop()
        }
    }

    // Main StackView for navigation
    StackView {
        id: stackView
        anchors.fill: parent
        initialItem: mainPage

        // Smooth transitions
        pushEnter: Transition {
            PropertyAnimation {
                property: "opacity"
                from: 0
                to: 1
                duration: 300
                easing.type: Easing.OutQuad
            }
        }

        pushExit: Transition {
            PropertyAnimation {
                property: "opacity"
                from: 1
                to: 0
                duration: 300
                easing.type: Easing.InQuad
            }
        }
    }

    // Alternative Loader for pages that expect pageLoader
    Loader {
        id: pageLoader
        anchors.fill: parent
        visible: false
        z: 100

        // When pageLoader is used, hide stackView
        onSourceChanged: {
            if (source.toString().length > 0) {
                visible = true
                stackView.visible = false
            }
        }

        // Function to switch back to stackView
        function hideLoader() {
            visible = false
            stackView.visible = true
            source = ""
        }
    }

    // Beautiful Main Page Component
    Rectangle {
        id: mainPage
        anchors.fill: parent

        // Beautiful animated gradient background
        gradient: Gradient {
            GradientStop { position: 0.0; color: "#0f0c29" }
            GradientStop { position: 0.3; color: "#24243e" }
            GradientStop { position: 0.6; color: "#302b63" }
            GradientStop { position: 1.0; color: "#0f0c29" }
        }

        // Animated particles background
        Repeater {
            model: 12
            Rectangle {
                width: 3 * dp
                height: 3 * dp
                radius: 1.5 * dp
                color: Qt.rgba(1, 1, 1, 0.1)
                x: Math.random() * parent.width
                y: Math.random() * parent.height

                SequentialAnimation on opacity {
                    running: true
                    loops: Animation.Infinite
                    NumberAnimation { to: 0.8; duration: 2000 + Math.random() * 1000 }
                    NumberAnimation { to: 0.1; duration: 2000 + Math.random() * 1000 }
                }

                SequentialAnimation on y {
                    running: true
                    loops: Animation.Infinite
                    NumberAnimation { to: parent.height + 50; duration: 8000 + Math.random() * 4000 }
                    PropertyAction { property: "y"; value: -50 }
                }
            }
        }

        Flickable {
            id: scrollView
            anchors.fill: parent
            anchors.margins: 20 * dp
            contentHeight: contentColumn.height + 40 * dp
            boundsBehavior: Flickable.DragOverBounds

            Column {
                id: contentColumn
                width: parent.width
                spacing: 32 * dp

                // Top spacer
                Item { height: 20 * dp; width: 1 }

                // Beautiful App Logo Section
                Column {
                    anchors.horizontalCenter: parent.horizontalCenter
                    spacing: 16 * dp

                    // Animated App Icon
                    Rectangle {
                        width: 100 * dp
                        height: 100 * dp
                        anchors.horizontalCenter: parent.horizontalCenter
                        radius: 50 * dp

                        gradient: Gradient {
                            GradientStop { position: 0.0; color: "#667eea" }
                            GradientStop { position: 1.0; color: "#764ba2" }
                        }

                        border.width: 3 * dp
                        border.color: Qt.rgba(1, 1, 1, 0.3)

                        // Rotation animation
                        RotationAnimation {
                            target: parent
                            from: 0
                            to: 360
                            duration: 20000
                            loops: Animation.Infinite
                            running: true
                        }

                        Text {
                            anchors.centerIn: parent
                            text: "🍽️"
                            font.pixelSize: 50 * dp

                            // Pulsing animation
                            SequentialAnimation on scale {
                                running: true
                                loops: Animation.Infinite
                                NumberAnimation { to: 1.1; duration: 1000; easing.type: Easing.InOutQuad }
                                NumberAnimation { to: 1.0; duration: 1000; easing.type: Easing.InOutQuad }
                            }
                        }
                    }

                    // App Title and Subtitle
                    Column {
                        anchors.horizontalCenter: parent.horizontalCenter
                        spacing: 8 * dp

                        Text {
                            text: "ByteBite"
                            font.family: "Arial Black, sans-serif"
                            font.pixelSize: 42 * dp
                            font.weight: Font.Bold
                            color: "#ffffff"
                            anchors.horizontalCenter: parent.horizontalCenter
                        }

                        Text {
                            text: "Delicious food, delivered fast 🚀"
                            font.family: "Arial, sans-serif"
                            font.pixelSize: 15 * dp
                            color: Qt.rgba(1, 1, 1, 0.8)
                            anchors.horizontalCenter: parent.horizontalCenter
                        }

                        // Feature badges
                        Row {
                            anchors.horizontalCenter: parent.horizontalCenter
                            spacing: 10 * dp

                            Repeater {
                                model: ["⚡ Fast", "🔥 Fresh", "💯 Quality"]
                                Rectangle {
                                    width: 65 * dp
                                    height: 26 * dp
                                    radius: 13 * dp
                                    color: Qt.rgba(1, 1, 1, 0.15)
                                    border.width: 1
                                    border.color: Qt.rgba(1, 1, 1, 0.3)

                                    Text {
                                        anchors.centerIn: parent
                                        text: modelData
                                        font.pixelSize: 10 * dp
                                        color: "#ffffff"
                                        font.weight: Font.Medium
                                    }
                                }
                            }
                        }
                    }
                }

                // Main CTA Section
                Column {
                    width: parent.width
                    spacing: 20 * dp

                    Text {
                        width: parent.width
                        text: "Ready to Order?"
                        font.family: "Arial, sans-serif"
                        font.pixelSize: 28 * dp
                        font.weight: Font.Bold
                        color: "white"
                        wrapMode: Text.WordWrap
                        horizontalAlignment: Text.AlignHCenter
                    }

                    Text {
                        width: parent.width
                        text: "Join thousands of food lovers and discover amazing restaurants near you!"
                        font.family: "Arial, sans-serif"
                        font.pixelSize: 14 * dp
                        color: Qt.rgba(1, 1, 1, 0.8)
                        wrapMode: Text.WordWrap
                        horizontalAlignment: Text.AlignHCenter
                        lineHeight: 1.4
                    }
                }

                // Beautiful CTA Button
                Rectangle {
                    width: parent.width * 0.85
                    height: 56 * dp
                    anchors.horizontalCenter: parent.horizontalCenter
                    radius: 28 * dp

                    gradient: Gradient {
                        GradientStop { position: 0.0; color: "#667eea" }
                        GradientStop { position: 1.0; color: "#764ba2" }
                    }

                    border.width: 2 * dp
                    border.color: Qt.rgba(1, 1, 1, 0.2)

                    // Drop shadow effect (simulated)
                    Rectangle {
                        anchors.centerIn: parent
                        anchors.verticalCenterOffset: 4 * dp
                        width: parent.width
                        height: parent.height
                        radius: parent.radius
                        color: Qt.rgba(0, 0, 0, 0.2)
                        z: -1
                    }

                    Row {
                        anchors.centerIn: parent
                        spacing: 10 * dp

                        Text {
                            text: "🚀"
                            font.pixelSize: 18 * dp
                        }

                        Text {
                            text: "START ORDERING"
                            font.family: "Arial, sans-serif"
                            font.pixelSize: 16 * dp
                            font.weight: Font.Bold
                            color: "#ffffff"
                            font.letterSpacing: 1
                        }
                    }

                    MouseArea {
                        id: orderButtonArea
                        anchors.fill: parent

                        onClicked: {
                            console.log("🚀 START ORDERING clicked - Loading login page...")
                            console.log("👤 User: Sumit-51")
                            console.log("🕒 Time: 2025-08-03 10:19:27 UTC")
                            stackView.push("loginpage.qml")
                        }

                        onPressed: {
                            parent.scale = 0.96
                            parent.opacity = 0.8
                        }

                        onReleased: {
                            parent.scale = 1.0
                            parent.opacity = 1.0
                        }

                        Behavior on scale {
                            NumberAnimation { duration: 150; easing.type: Easing.OutQuad }
                        }

                        Behavior on opacity {
                            NumberAnimation { duration: 150 }
                        }
                    }
                }

                // Featured Restaurants Preview
                Column {
                    width: parent.width
                    spacing: 20 * dp

                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: "Featured Restaurants"
                        font.family: "Arial, sans-serif"
                        font.pixelSize: 20 * dp
                        font.weight: Font.Bold
                        color: "white"
                    }

                    // Restaurant cards
                    Grid {
                        anchors.horizontalCenter: parent.horizontalCenter
                        columns: 2
                        spacing: 12 * dp

                        Repeater {
                            model: [
                                {name: "Pratima\nRestaurant", emoji: "🏪", color: "#ef4444"},
                                {name: "HK\nRestaurant", emoji: "🏨", color: "#06b6d4"},
                                {name: "Sherpa\nHotel", emoji: "🏔️", color: "#8b5cf6"},
                                {name: "Night\nOrder", emoji: "🌙", color: "#6366f1"}
                            ]

                            Rectangle {
                                width: (parent.parent.width - 12 * dp) / 2
                                height: 100 * dp
                                radius: 16 * dp
                                color: Qt.rgba(1, 1, 1, 0.1)
                                border.width: 1
                                border.color: Qt.rgba(1, 1, 1, 0.2)

                                Column {
                                    anchors.centerIn: parent
                                    spacing: 8 * dp

                                    Rectangle {
                                        anchors.horizontalCenter: parent.horizontalCenter
                                        width: 40 * dp
                                        height: 40 * dp
                                        radius: 8 * dp
                                        color: modelData.color

                                        Text {
                                            anchors.centerIn: parent
                                            text: modelData.emoji
                                            font.pixelSize: 20 * dp
                                        }
                                    }

                                    Text {
                                        anchors.horizontalCenter: parent.horizontalCenter
                                        text: modelData.name
                                        font.family: "Arial, sans-serif"
                                        font.pixelSize: 11 * dp
                                        font.weight: Font.Bold
                                        color: "#ffffff"
                                        horizontalAlignment: Text.AlignHCenter
                                        lineHeight: 1.2
                                    }
                                }
                            }
                        }
                    }
                }

                // Why Choose Us Section
                Rectangle {
                    width: parent.width
                    height: 100 * dp
                    radius: 20 * dp
                    color: Qt.rgba(1, 1, 1, 0.1)
                    border.color: Qt.rgba(1, 1, 1, 0.2)
                    border.width: 1

                    Column {
                        anchors.centerIn: parent
                        spacing: 12 * dp

                        Text {
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: "Why Choose ByteBite?"
                            font.family: "Arial, sans-serif"
                            font.pixelSize: 16 * dp
                            font.weight: Font.Bold
                            color: "white"
                        }

                        Row {
                            anchors.horizontalCenter: parent.horizontalCenter
                            spacing: 30 * dp

                            Column {
                                spacing: 4 * dp
                                Text {
                                    anchors.horizontalCenter: parent.horizontalCenter
                                    text: "⚡"
                                    font.pixelSize: 18 * dp
                                }
                                Text {
                                    anchors.horizontalCenter: parent.horizontalCenter
                                    text: "Fast Delivery"
                                    font.family: "Arial, sans-serif"
                                    font.pixelSize: 11 * dp
                                    color: "white"
                                    font.weight: Font.Medium
                                }
                            }

                            Column {
                                spacing: 4 * dp
                                Text {
                                    anchors.horizontalCenter: parent.horizontalCenter
                                    text: "🎓"
                                    font.pixelSize: 18 * dp
                                }
                                Text {
                                    anchors.horizontalCenter: parent.horizontalCenter
                                    text: "Student Discounts"
                                    font.family: "Arial, sans-serif"
                                    font.pixelSize: 11 * dp
                                    color: "white"
                                    font.weight: Font.Medium
                                }
                            }

                            Column {
                                spacing: 4 * dp
                                Text {
                                    anchors.horizontalCenter: parent.horizontalCenter
                                    text: "💯"
                                    font.pixelSize: 18 * dp
                                }
                                Text {
                                    anchors.horizontalCenter: parent.horizontalCenter
                                    text: "Quality Food"
                                    font.family: "Arial, sans-serif"
                                    font.pixelSize: 11 * dp
                                    color: "white"
                                    font.weight: Font.Medium
                                }
                            }
                        }
                    }
                }

                // Footer
                Column {
                    anchors.horizontalCenter: parent.horizontalCenter
                    spacing: 8 * dp

                    Text {
                        text: "ByteBite © 2025"
                        font.family: "Arial, sans-serif"
                        font.pixelSize: 12 * dp
                        color: Qt.rgba(1, 1, 1, 0.6)
                        anchors.horizontalCenter: parent.horizontalCenter
                    }

                    Text {
                        text: "Made with ❤️ for food lovers"
                        font.family: "Arial, sans-serif"
                        font.pixelSize: 10 * dp
                        color: Qt.rgba(1, 1, 1, 0.5)
                        anchors.horizontalCenter: parent.horizontalCenter
                    }
                }

                // Bottom spacer
                Item { height: 30 * dp; width: 1 }
            }
        }
    }

    // Debug output
    Component.onCompleted: {
        console.log("🚀 ByteBite - Beautiful Food Delivery App")
        console.log("✅ Main.qml loaded successfully (QtQuick 2.15 compatible)")
        console.log("✅ StackView available globally")
        console.log("✅ PageLoader available for backward compatibility")
        console.log("✅ Navigation functions ready")
        console.log("👤 User: Sumit-51")
        console.log("🕒 Time: 2025-08-03 10:19:27 UTC")
        console.log("🎨 Beautiful animations and design loaded!")
    }
}
