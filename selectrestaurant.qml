import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Rectangle {
    id: restaurantRoot
    anchors.fill: parent

    property string selectedRestaurant: ""
    property real dp: Math.min(width / 375, height / 812)

    // Mobile gradient
    gradient: Gradient {
        GradientStop { position: 0.0; color: "#f8fafc" }
        GradientStop { position: 1.0; color: "#e2e8f0" }
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        // Mobile Header
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 80 * dp
            color: "#ffffff"

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 16 * dp
                anchors.rightMargin: 16 * dp

                Rectangle {
                    Layout.preferredWidth: 40 * dp
                    Layout.preferredHeight: 40 * dp
                    Layout.alignment: Qt.AlignVCenter
                    radius: 20 * dp
                    color: backMouseArea.pressed ? "#f1f5f9" : "#ffffff"
                    border.width: 1
                    border.color: "#e2e8f0"

                    Text {
                        anchors.centerIn: parent
                        text: "←"
                        color: "#64748b"
                        font.pixelSize: 16 * dp
                    }

                    MouseArea {
                        id: backMouseArea
                        anchors.fill: parent
                        onClicked: pageLoader.source = "loginpage.qml"
                    }
                }

                Item { Layout.fillWidth: true }

                Text {
                    text: "Choose Restaurant"
                    font.pixelSize: 18 * dp
                    font.weight: Font.Bold
                    color: "#1e293b"
                    Layout.alignment: Qt.AlignVCenter
                }

                Item { Layout.fillWidth: true }

                // MY ORDERS BUTTON
                Rectangle {
                    Layout.preferredWidth: 90 * dp
                    Layout.preferredHeight: 32 * dp
                    Layout.alignment: Qt.AlignVCenter
                    radius: 16 * dp
                    color: "#3b82f6"

                    Text {
                        anchors.centerIn: parent
                        text: "📋 My Orders"
                        color: "white"
                        font.pixelSize: 10 * dp
                        font.weight: Font.Bold
                    }

                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            console.log("🔄 Opening My Orders page")
                            pageLoader.source = "OrderStatus.qml"
                        }
                    }
                }
            }
        }

        // Mobile content
        ScrollView {
            Layout.fillWidth: true
            Layout.fillHeight: true
            contentWidth: parent.width
            clip: true

            ColumnLayout {
                width: parent.width
                spacing: 16 * dp

                // Mobile welcome
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 80 * dp
                    Layout.margins: 16 * dp
                    radius: 12 * dp
                    color: "#ffffff"
                    border.width: 1
                    border.color: "#e2e8f0"

                    RowLayout {
                        anchors.centerIn: parent
                        spacing: 12 * dp

                        Text {
                            text: "🍽️"
                            font.pixelSize: 24 * dp
                        }

                        ColumnLayout {
                            spacing: 2 * dp

                            Text {
                                text: "Select Restaurant"
                                font.pixelSize: 16 * dp
                                font.weight: Font.Bold
                                color: "#1e293b"
                            }

                            Text {
                                text: "Fresh food delivered"
                                font.pixelSize: 12 * dp
                                color: "#64748b"
                            }
                        }
                    }
                }

                // Mobile restaurant list
                ColumnLayout {
                    Layout.fillWidth: true
                    Layout.margins: 16 * dp
                    spacing: 12 * dp

                    property var restaurants: [
                        {
                            id: "pratima",
                            name: "Pratima Underground",
                            cuisine: "Nepali Cuisine",
                            emoji: "🏔️",
                            color: "#ef4444",
                            time: "25-35 min",
                            rating: "4.8"
                        },
                        {
                            id: "hk",
                            name: "HK Restaurant",
                            cuisine: "Asian Fusion",
                            emoji: "🥢",
                            color: "#3b82f6",
                            time: "20-30 min",
                            rating: "4.6"
                        },
                        {
                            id: "sherpa",
                            name: "Sherpa Hotel",
                            cuisine: "Mountain Food",
                            emoji: "⛰️",
                            color: "#8b5cf6",
                            time: "30-40 min",
                            rating: "4.7"
                        },
                        {
                            id: "pawan",
                            name: "Pawan Sweet's",
                            cuisine: "Sweets & Snacks",
                            emoji: "🍰",
                            color: "#f59e0b",
                            time: "15-25 min",
                            rating: "4.9"
                        },
                        {
                            id: "nightorder",
                            name: "Night Order",
                            cuisine: "Late Night",
                            emoji: "🌙",
                            color: "#6366f1",
                            time: "20-30 min",
                            rating: "4.5"
                        }
                    ]

                    Repeater {
                        model: parent.restaurants

                        Rectangle {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 100 * dp
                            radius: 12 * dp
                            color: "#ffffff"
                            border.width: selectedRestaurant === modelData.id ? 2 : 1
                            border.color: selectedRestaurant === modelData.id ? modelData.color : "#e2e8f0"

                            scale: restaurantMouseArea.pressed ? 0.98 : 1.0
                            Behavior on scale { NumberAnimation { duration: 150 } }

                            RowLayout {
                                anchors.fill: parent
                                anchors.margins: 12 * dp
                                spacing: 12 * dp

                                // Mobile restaurant icon
                                Rectangle {
                                    Layout.preferredWidth: 60 * dp
                                    Layout.preferredHeight: 60 * dp
                                    Layout.alignment: Qt.AlignVCenter
                                    radius: 12 * dp
                                    color: modelData.color

                                    Text {
                                        anchors.centerIn: parent
                                        text: modelData.emoji
                                        font.pixelSize: 24 * dp
                                    }
                                }

                                // Mobile restaurant info
                                ColumnLayout {
                                    Layout.fillWidth: true
                                    spacing: 4 * dp

                                    Text {
                                        text: modelData.name
                                        font.pixelSize: 16 * dp
                                        font.weight: Font.Bold
                                        color: "#1e293b"
                                    }

                                    Text {
                                        text: modelData.cuisine
                                        font.pixelSize: 12 * dp
                                        color: "#64748b"
                                    }

                                    RowLayout {
                                        spacing: 12 * dp

                                        RowLayout {
                                            spacing: 2 * dp
                                            Text {
                                                text: "★"
                                                color: "#f59e0b"
                                                font.pixelSize: 10 * dp
                                            }
                                            Text {
                                                text: modelData.rating
                                                font.pixelSize: 10 * dp
                                                color: "#64748b"
                                            }
                                        }

                                        Text {
                                            text: "🕒 " + modelData.time
                                            font.pixelSize: 10 * dp
                                            color: "#64748b"
                                        }
                                    }
                                }

                                // Mobile selection indicator
                                Rectangle {
                                    Layout.preferredWidth: 20 * dp
                                    Layout.preferredHeight: 20 * dp
                                    Layout.alignment: Qt.AlignVCenter
                                    radius: 10 * dp
                                    color: "transparent"
                                    border.width: 2
                                    border.color: selectedRestaurant === modelData.id ? modelData.color : "#cbd5e1"

                                    Rectangle {
                                        anchors.centerIn: parent
                                        width: 10 * dp
                                        height: 10 * dp
                                        radius: 5 * dp
                                        color: selectedRestaurant === modelData.id ? modelData.color : "transparent"

                                        Behavior on color { ColorAnimation { duration: 200 } }
                                    }
                                }
                            }

                            MouseArea {
                                id: restaurantMouseArea
                                anchors.fill: parent

                                onClicked: {
                                    selectedRestaurant = modelData.id
                                    console.log("Selected restaurant:", modelData.name)
                                }
                            }
                        }
                    }
                }

                // Mobile continue button
                Rectangle {
                    Layout.alignment: Qt.AlignHCenter
                    Layout.preferredWidth: parent.width - 32 * dp
                    Layout.preferredHeight: 50 * dp
                    Layout.margins: 16 * dp
                    radius: 25 * dp
                    color: selectedRestaurant !== "" ? "#3b82f6" : "#cbd5e1"
                    enabled: selectedRestaurant !== ""

                    scale: continueMouseArea.pressed && parent.enabled ? 0.95 : 1.0
                    Behavior on scale { NumberAnimation { duration: 150 } }

                    RowLayout {
                        anchors.centerIn: parent
                        spacing: 8 * dp

                        Text {
                            text: "Continue"
                            color: "#ffffff"
                            font.pixelSize: 16 * dp
                            font.weight: Font.Medium
                        }

                        Text {
                            text: "→"
                            color: "#ffffff"
                            font.pixelSize: 16 * dp
                        }
                    }

                    MouseArea {
                        id: continueMouseArea
                        anchors.fill: parent
                        enabled: parent.enabled

                        onClicked: {
                            if (selectedRestaurant !== "") {
                                console.log("Navigating to menu for:", selectedRestaurant)
                                switch(selectedRestaurant) {
                                    case "pratima":
                                        pageLoader.source = "pratimamenu.qml"
                                        break
                                    case "hk":
                                        pageLoader.source = "hkmenu.qml"
                                        break
                                    case "sherpa":
                                        pageLoader.source = "sherpamenu.qml"
                                        break
                                    case "pawan":
                                        pageLoader.source = "pawanmenu.qml"
                                        break
                                    case "nightorder":
                                        pageLoader.source = "nightordermenu.qml"
                                        break
                                }
                            }
                        }
                    }
                }

                Item { Layout.preferredHeight: 20 * dp }
            }
        }
    }
}
