//loginpage.qml


import QtQuick 6.5
import QtQuick.Controls 6.5
import QtQuick.Layouts
import FirebaseAuth 1.0

Rectangle {
    id: loginRoot
    anchors.fill: parent

    property bool isSignupMode: false
    property bool showEmailVerification: false
    property bool showPasswordReset: false
    property bool showPasswordResetSuccess: false

    function showSmartErrorMessage(message) {
        var displayMessage = message
        var displayColor = "#ef4444"
        var displayIcon = "⚠️"
        var shouldVibrate = false

        messagePopAnimation.stop()
        messageShakeAnimation.stop()

        if (message.toLowerCase().includes("password") && (message.toLowerCase().includes("invalid") || message.toLowerCase().includes("incorrect") || message.toLowerCase().includes("wrong"))) {
            displayMessage = "🔒 **Wrong Password**\n\nThe password you entered is incorrect.\n\n• Double-check your password\n• Try 'Forgot Password' if you can't remember\n• Make sure Caps Lock is off"
            displayColor = "#dc2626"
            displayIcon = "🔒"
            shouldVibrate = true
        } else if (message.toLowerCase().includes("user-not-found") || (message.toLowerCase().includes("email") && (message.toLowerCase().includes("not found") || message.toLowerCase().includes("email_not_found")))) {
            displayMessage = "❌ **Email Not Registered**\n\nNo account found with this email address.\n\n• Check your email spelling carefully\n• Try a different email address\n• Create a new account using 'Sign Up'"
            displayColor = "#dc2626"
            displayIcon = "❌"
            shouldVibrate = true
        } else if (message.toLowerCase().includes("invalid-credential") || message.toLowerCase().includes("invalid credential")) {
            displayMessage = "🚫 **Login Failed**\n\nEither your email or password is wrong.\n\n• Verify your email address\n• Check your password\n• Try 'Forgot Password' if needed"
            displayColor = "#dc2626"
            displayIcon = "🚫"
            shouldVibrate = true
        } else if (message.toLowerCase().includes("email") && message.toLowerCase().includes("verification")) {
            displayMessage = "📧 **Email Verification Required**\n\nPlease verify your email before logging in.\n\n• Check your email inbox\n• Click the verification link\n• Check spam folder if not found"
            displayColor = "#fb923c"
            displayIcon = "📧"
        } else if (message.toLowerCase().includes("already exists") || message.toLowerCase().includes("email_exists") || message.toLowerCase().includes("email-already-in-use")) {
            displayMessage = "⚠️ **Account Already Exists**\n\nThis email is already registered.\n\n• Try logging in instead\n• Use 'Forgot Password' if you forgot your password\n• Use a different email for new account"
            displayColor = "#f59e0b"
            displayIcon = "⚠️"
        } else if (message.toLowerCase().includes("weak password") || message.toLowerCase().includes("6 characters")) {
            displayMessage = "🔐 **Password Too Weak**\n\nYour password doesn't meet requirements.\n\n• Use at least 6 characters\n• Mix letters, numbers, and symbols\n• Avoid common words"
            displayColor = "#f59e0b"
            displayIcon = "🔐"
        } else if (message.toLowerCase().includes("too many") || message.toLowerCase().includes("attempts") || message.toLowerCase().includes("too-many-requests")) {
            displayMessage = "⏳ **Too Many Attempts**\n\nAccount temporarily locked for security.\n\n• Wait 5-10 minutes\n• Try again later\n• Use 'Forgot Password' if you keep forgetting"
            displayColor = "#f59e0b"
            displayIcon = "⏳"
        } else if (message.toLowerCase().includes("network") || message.toLowerCase().includes("connection") || message.toLowerCase().includes("timeout")) {
            displayMessage = "🌐 **Connection Problem**\n\nUnable to connect to server.\n\n• Check your internet connection\n• Try again in a moment\n• Switch to mobile data if on WiFi"
            displayColor = "#f59e0b"
            displayIcon = "🌐"
        } else if (message.toLowerCase().includes("invalid email") || message.toLowerCase().includes("invalid-email") || message.toLowerCase().includes("badly formatted")) {
            displayMessage = "📧 **Invalid Email Format**\n\nPlease enter a valid email address.\n\n• Include @ symbol\n• Add domain (e.g., @gmail.com)\n• Example: user@example.com"
            displayColor = "#f59e0b"
            displayIcon = "📧"
            shouldVibrate = true
        } else if (message.toLowerCase().includes("user disabled") || message.toLowerCase().includes("user-disabled") || message.toLowerCase().includes("disabled")) {
            displayMessage = "🚫 **Account Disabled**\n\nThis account has been disabled.\n\n• Contact support for assistance\n• Check your email for more information\n• This may be due to policy violations"
            displayColor = "#dc2626"
            displayIcon = "🚫"
        } else if (message.toLowerCase().includes("system not ready")) {
            displayMessage = "⏳ **System Starting Up**\n\nPlease wait while system initializes.\n\n• Try again in a few seconds\n• System is loading components\n• This usually takes 10-20 seconds"
            displayColor = "#f59e0b"
            displayIcon = "⏳"
        } else if (message.toLowerCase().includes("missing") && message.toLowerCase().includes("credentials")) {
            displayMessage = "📝 **Missing Information**\n\nBoth email and password are required.\n\n• Fill in your email address\n• Enter your password\n• Both fields must be completed"
            displayColor = "#f59e0b"
            displayIcon = "📝"
            shouldVibrate = true
        } else {
            displayMessage = message
            displayColor = message.includes("✅") || message.includes("successfully") ? "#10b981" : "#ef4444"
            displayIcon = message.includes("✅") || message.includes("successfully") ? "✅" : "⚠️"
        }

        statusText.text = displayMessage
        statusText.color = displayColor
        statusIcon.text = displayIcon
        statusText.visible = true
        statusContainer.visible = true

        if (shouldVibrate) {
            messageShakeAnimation.start()
        }
        messagePopAnimation.start()

        if (displayColor === "#10b981") {
            statusHideTimer.restart()
        }
    }

    function showLoadingFeedback(operation) {
        if (operation === "login") {
            statusText.text = "🔄 Verifying your credentials with secure servers."
            statusText.color = "#3b82f6"
            statusIcon.text = "🔄"
            statusText.visible = true
            statusContainer.visible = true
        } else if (operation === "signup") {
            statusText.text = "🔄 **Creating Your Account**\n\nPlease wait a moment."
            statusText.color = "#8b5cf6"
            statusIcon.text = "🔄"
            statusText.visible = true
            statusContainer.visible = true
        }
    }

    SequentialAnimation {
        id: messagePopAnimation
        NumberAnimation {
            target: statusContainer
            property: "scale"
            from: 0.8
            to: 1.1
            duration: 150
        }
        NumberAnimation {
            target: statusContainer
            property: "scale"
            from: 1.1
            to: 1.0
            duration: 150
        }
    }

    SequentialAnimation {
        id: messageShakeAnimation
        NumberAnimation {
            target: statusContainer
            property: "x"
            to: statusContainer.x + 10
            duration: 100
        }
        NumberAnimation {
            target: statusContainer
            property: "x"
            to: statusContainer.x - 10
            duration: 100
        }
        NumberAnimation {
            target: statusContainer
            property: "x"
            to: statusContainer.x + 5
            duration: 100
        }
        NumberAnimation {
            target: statusContainer
            property: "x"
            to: statusContainer.x
            duration: 100
        }
    }

    Timer {
        id: statusHideTimer
        interval: 5000
        onTriggered: {
            statusText.visible = false
            statusContainer.visible = false
        }
    }

    gradient: Gradient {
        GradientStop { position: 0.0; color: "#f8fafc" }
        GradientStop { position: 0.4; color: "#f1f5f9" }
        GradientStop { position: 0.8; color: "#e2e8f0" }
        GradientStop { position: 1.0; color: "#cbd5e1" }
    }

    Rectangle {
        id: emailVerificationModal
        anchors.fill: parent
        color: Qt.rgba(0, 0, 0, 0.5)
        visible: showEmailVerification
        z: 1000

        MouseArea {
            anchors.fill: parent
            onClicked: {}
        }

        Rectangle {
            anchors.centerIn: parent
            width: Math.min(350, parent.width - 40)
            height: Math.min(400, parent.height - 80)
            radius: 20
            color: "#ffffff"
            border.width: 1
            border.color: "#e2e8f0"

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 30
                spacing: 20

                Rectangle {
                    Layout.alignment: Qt.AlignRight
                    Layout.topMargin: -15
                    Layout.rightMargin: -15
                    width: 32
                    height: 32
                    radius: 16
                    color: emailVerifCloseMouseArea.pressed ? "#f1f5f9" : "#ffffff"
                    border.width: 1
                    border.color: "#e2e8f0"

                    Text {
                        anchors.centerIn: parent
                        text: "✕"
                        color: "#64748b"
                        font.pixelSize: 14
                        font.weight: Font.Bold
                    }

                    MouseArea {
                        id: emailVerifCloseMouseArea
                        anchors.fill: parent
                        onClicked: {
                            showEmailVerification = false
                            isSignupMode = false
                            passwordField.text = ""
                            statusText.visible = false
                            statusContainer.visible = false
                        }
                    }
                }

                Rectangle {
                    Layout.alignment: Qt.AlignHCenter
                    Layout.preferredWidth: 80
                    Layout.preferredHeight: 80
                    radius: 40
                    color: "#f0fdf4"
                    border.width: 2
                    border.color: "#22c55e"

                    Text {
                        anchors.centerIn: parent
                        text: "📧"
                        font.pixelSize: 32
                    }
                }

                Text {
                    text: "Account Created Successfully!"
                    font.family: "system-ui"
                    font.pixelSize: 18
                    font.weight: Font.Bold
                    color: "#1e293b"
                    Layout.alignment: Qt.AlignHCenter
                    horizontalAlignment: Text.AlignHCenter
                }

                Text {
                    text: "🎉 Please click the verification link to activate your account"
                    font.family: "system-ui"
                    font.pixelSize: 14
                    color: "#64748b"
                    Layout.fillWidth: true
                    horizontalAlignment: Text.AlignHCenter
                    wrapMode: Text.WordWrap
                    lineHeight: 1.5
                }

                Item { Layout.fillHeight: true }

                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 48
                    radius: 12
                    color: "#3b82f6"

                    Text {
                        anchors.centerIn: parent
                        text: "Continue to Login"
                        font.family: "system-ui"
                        font.pixelSize: 14
                        font.weight: Font.Medium
                        color: "#ffffff"
                    }

                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            showEmailVerification = false
                            isSignupMode = false
                            passwordField.text = ""
                            statusText.visible = false
                            statusContainer.visible = false
                        }
                    }
                }
            }
        }
    }

    Rectangle {
        id: passwordResetModal
        anchors.fill: parent
        color: Qt.rgba(0, 0, 0, 0.5)
        visible: showPasswordReset
        z: 1000

        MouseArea {
            anchors.fill: parent
            onClicked: {}
        }

        Rectangle {
            anchors.centerIn: parent
            width: Math.min(350, parent.width - 40)
            height: Math.min(showPasswordResetSuccess ? 350 : 400, parent.height - 80)
            radius: 20
            color: "#ffffff"
            border.width: 1
            border.color: "#e2e8f0"

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 30
                spacing: 20

                Rectangle {
                    Layout.alignment: Qt.AlignRight
                    Layout.topMargin: -15
                    Layout.rightMargin: -15
                    width: 32
                    height: 32
                    radius: 16
                    color: passwordResetCloseMouseArea.pressed ? "#f1f5f9" : "#ffffff"
                    border.width: 1
                    border.color: "#e2e8f0"

                    Text {
                        anchors.centerIn: parent
                        text: "✕"
                        color: "#64748b"
                        font.pixelSize: 14
                        font.weight: Font.Bold
                    }

                    MouseArea {
                        id: passwordResetCloseMouseArea
                        anchors.fill: parent
                        onClicked: {
                            showPasswordReset = false
                            showPasswordResetSuccess = false
                            resetEmailField.text = ""
                        }
                    }
                }

                Rectangle {
                    Layout.alignment: Qt.AlignHCenter
                    Layout.preferredWidth: 80
                    Layout.preferredHeight: 80
                    radius: 40
                    color: showPasswordResetSuccess ? "#f0fdf4" : "#fef3c7"
                    border.width: 2
                    border.color: showPasswordResetSuccess ? "#22c55e" : "#f59e0b"

                    Text {
                        anchors.centerIn: parent
                        text: showPasswordResetSuccess ? "✅" : "🔑"
                        font.pixelSize: 32
                    }
                }

                Text {
                    text: showPasswordResetSuccess ? "Reset Link Sent!" : "Reset Password"
                    font.family: "system-ui"
                    font.pixelSize: 18
                    font.weight: Font.Bold
                    color: "#1e293b"
                    Layout.alignment: Qt.AlignHCenter
                    horizontalAlignment: Text.AlignHCenter
                }

                Text {
                    text: showPasswordResetSuccess ?
                          "📧 Check your email inbox for password reset instructions. Don't forget to check your spam folder!" :
                          "Enter your email address and we'll send you a secure link to reset your password."
                    font.family: "system-ui"
                    font.pixelSize: 14
                    color: "#64748b"
                    Layout.fillWidth: true
                    horizontalAlignment: Text.AlignHCenter
                    wrapMode: Text.WordWrap
                    lineHeight: 1.5
                }

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 8
                    visible: !showPasswordResetSuccess

                    Text {
                        text: "Email Address"
                        font.family: "system-ui"
                        font.pixelSize: 14
                        font.weight: Font.Medium
                        color: "#374151"
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 48
                        radius: 12
                        color: "#ffffff"
                        border.width: 2
                        border.color: resetEmailField.activeFocus ? "#3b82f6" : "#e2e8f0"

                        RowLayout {
                            anchors.fill: parent
                            anchors.margins: 16
                            spacing: 12

                            Rectangle {
                                width: 24
                                height: 24
                                radius: 12
                                color: "#3b82f6"

                                Text {
                                    anchors.centerIn: parent
                                    text: "@"
                                    color: "#ffffff"
                                    font.pixelSize: 12
                                    font.weight: Font.Bold
                                }
                            }

                            TextInput {
                                id: resetEmailField
                                Layout.fillWidth: true
                                font.family: "system-ui"
                                font.pixelSize: 14
                                color: "#1f2937"
                                selectByMouse: true
                                verticalAlignment: TextInput.AlignVCenter

                                Text {
                                    anchors.left: parent.left
                                    anchors.verticalCenter: parent.verticalCenter
                                    text: "Enter your email address"
                                    font.family: parent.font.family
                                    font.pixelSize: parent.font.pixelSize
                                    color: "#9ca3af"
                                    visible: resetEmailField.text.length === 0 && !resetEmailField.activeFocus
                                }
                            }
                        }
                    }
                }

                Item { Layout.fillHeight: true }

                RowLayout {
                    Layout.fillWidth: true
                    spacing: 12

                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 48
                        radius: 12
                        color: cancelResetMouseArea.pressed ? "#f8fafc" : "#ffffff"
                        border.width: 2
                        border.color: "#e2e8f0"
                        visible: !showPasswordResetSuccess

                        Text {
                            anchors.centerIn: parent
                            text: "Cancel"
                            font.family: "system-ui"
                            font.pixelSize: 14
                            font.weight: Font.Medium
                            color: "#64748b"
                        }

                        MouseArea {
                            id: cancelResetMouseArea
                            anchors.fill: parent
                            onClicked: {
                                showPasswordReset = false
                                showPasswordResetSuccess = false
                                resetEmailField.text = ""
                            }
                        }
                    }

                    Rectangle {
                        Layout.fillWidth: showPasswordResetSuccess ? 1 : 1
                        Layout.preferredHeight: 48
                        radius: 12
                        color: showPasswordResetSuccess ? "#22c55e" : "#f59e0b"

                        Text {
                            anchors.centerIn: parent
                            text: showPasswordResetSuccess ? "Got It!" : "Send Reset Link"
                            font.family: "system-ui"
                            font.pixelSize: 14
                            font.weight: Font.Medium
                            color: "#ffffff"
                        }

                        MouseArea {
                            anchors.fill: parent
                            onClicked: {
                                if (showPasswordResetSuccess) {
                                    showPasswordReset = false
                                    showPasswordResetSuccess = false
                                    resetEmailField.text = ""
                                } else {
                                    if (resetEmailField.text.trim().length > 0) {
                                        showLoadingFeedback("password_reset")
                                        firebaseAuth.sendPasswordReset(resetEmailField.text.trim())
                                    } else {
                                        showSmartErrorMessage("Please enter your email address to reset password")
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 70
            color: "#ffffff"
            border.width: 1
            border.color: "#e2e8f0"

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 20
                anchors.rightMargin: 20

                Rectangle {
                    Layout.preferredWidth: 80
                    Layout.preferredHeight: 36
                    Layout.alignment: Qt.AlignVCenter
                    radius: 10
                    color: backMouseArea.pressed ? "#f1f5f9" : "#ffffff"
                    border.width: 1
                    border.color: "#e2e8f0"

                    RowLayout {
                        anchors.centerIn: parent
                        spacing: 6

                        Text {
                            text: "←"
                            color: "#64748b"
                            font.pixelSize: 16
                        }

                        Text {
                            text: "Back"
                            color: "#64748b"
                            font.family: "system-ui"
                            font.pixelSize: 12
                            font.weight: Font.Medium
                        }
                    }

                    MouseArea {
                        id: backMouseArea
                        anchors.fill: parent
                        onClicked: {
                            stackView.push("Main.qml")
                        }
                    }
                }

                Item { Layout.fillWidth: true }

                Text {
                    text: "ByteBite Login"
                    font.family: "system-ui"
                    font.pixelSize: 20
                    font.weight: Font.Bold
                    color: "#1e293b"
                    Layout.alignment: Qt.AlignVCenter
                }

                Item { Layout.fillWidth: true }

                Rectangle {
                    Layout.preferredWidth: 100
                    Layout.preferredHeight: 36
                    Layout.alignment: Qt.AlignVCenter
                    radius: 18
                    color: "#f8fafc"
                    border.width: 1
                    border.color: "#e2e8f0"

                    RowLayout {
                        anchors.centerIn: parent
                        spacing: 6

                        Rectangle {
                            Layout.preferredWidth: 20
                            Layout.preferredHeight: 20
                            radius: 10
                            color: "#3b82f6"

                            Text {
                                anchors.centerIn: parent
                                text: "S"
                                color: "white"
                                font.pixelSize: 10
                                font.weight: Font.Bold
                            }
                        }

                        Text {
                            text: "welcome"
                            color: "#475569"
                            font.family: "system-ui"
                            font.pixelSize: 11
                            font.weight: Font.Medium
                        }
                    }
                }
            }
        }

        ScrollView {
            Layout.fillWidth: true
            Layout.fillHeight: true
            contentWidth: parent.width
            ScrollBar.horizontal.policy: ScrollBar.AlwaysOff

            ColumnLayout {
                width: loginRoot.width
                spacing: 20

                Item { Layout.preferredHeight: 20 }

                Rectangle {
                    Layout.alignment: Qt.AlignHCenter
                    Layout.preferredWidth: Math.min(350, parent.width - 40)
                    Layout.preferredHeight: 600
                    radius: 16
                    color: "#ffffff"
                    border.width: 1
                    border.color: "#e2e8f0"

                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: 30
                        spacing: 20

                        ColumnLayout {
                            Layout.alignment: Qt.AlignHCenter
                            spacing: 12

                            Rectangle {
                                Layout.alignment: Qt.AlignHCenter
                                Layout.preferredWidth: 60
                                Layout.preferredHeight: 60
                                radius: 12
                                color: "#f97316"

                                Text {
                                    anchors.centerIn: parent
                                    text: "🍽️"
                                    font.pixelSize: 24
                                }
                            }

                            Text {
                                text: "Welcome to ByteBite"
                                font.family: "system-ui"
                                font.pixelSize: 22
                                font.weight: Font.Bold
                                color: "#1e293b"
                                Layout.alignment: Qt.AlignHCenter
                            }

                            Text {
                                text: isSignupMode ? "Create your account to get started" : "Sign in to your account"
                                font.family: "system-ui"
                                font.pixelSize: 14
                                color: "#64748b"
                                Layout.alignment: Qt.AlignHCenter
                            }
                        }

                        Rectangle {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 44
                            radius: 12
                            color: "#f8fafc"
                            border.width: 1
                            border.color: "#e2e8f0"

                            RowLayout {
                                anchors.fill: parent
                                anchors.margins: 4
                                spacing: 0

                                Rectangle {
                                    Layout.fillWidth: true
                                    Layout.fillHeight: true
                                    radius: 8
                                    color: !isSignupMode ? "#3b82f6" : "transparent"

                                    Behavior on color { ColorAnimation { duration: 200 } }

                                    Text {
                                        anchors.centerIn: parent
                                        text: "Login"
                                        color: !isSignupMode ? "#ffffff" : "#64748b"
                                        font.family: "system-ui"
                                        font.pixelSize: 14
                                        font.weight: Font.Medium
                                    }

                                    MouseArea {
                                        anchors.fill: parent
                                        onClicked: {
                                            isSignupMode = false
                                            statusText.visible = false
                                            statusContainer.visible = false
                                            actionButton.enabled = true
                                        }
                                    }
                                }

                                Rectangle {
                                    Layout.fillWidth: true
                                    Layout.fillHeight: true
                                    radius: 8
                                    color: isSignupMode ? "#8b5cf6" : "transparent"

                                    Behavior on color { ColorAnimation { duration: 200 } }

                                    Text {
                                        anchors.centerIn: parent
                                        text: "Sign Up"
                                        color: isSignupMode ? "#ffffff" : "#64748b"
                                        font.family: "system-ui"
                                        font.pixelSize: 14
                                        font.weight: Font.Medium
                                    }

                                    MouseArea {
                                        anchors.fill: parent
                                        onClicked: {
                                            isSignupMode = true
                                            statusText.visible = false
                                            statusContainer.visible = false
                                            actionButton.enabled = true
                                        }
                                    }
                                }
                            }
                        }

                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 8

                            Text {
                                text: "Email Address"
                                font.family: "system-ui"
                                font.pixelSize: 14
                                font.weight: Font.Medium
                                color: "#374151"
                            }

                            Rectangle {
                                Layout.fillWidth: true
                                Layout.preferredHeight: 48
                                radius: 12
                                color: "#ffffff"
                                border.width: 2
                                border.color: emailField.activeFocus ? (isSignupMode ? "#8b5cf6" : "#3b82f6") : "#e2e8f0"

                                Behavior on border.color { ColorAnimation { duration: 200 } }

                                RowLayout {
                                    anchors.fill: parent
                                    anchors.margins: 16
                                    spacing: 12

                                    Rectangle {
                                        width: 20
                                        height: 20
                                        radius: 10
                                        color: isSignupMode ? "#8b5cf6" : "#3b82f6"

                                        Text {
                                            anchors.centerIn: parent
                                            text: "@"
                                            color: "#ffffff"
                                            font.pixelSize: 12
                                            font.weight: Font.Bold
                                        }
                                    }

                                    TextInput {
                                        id: emailField
                                        Layout.fillWidth: true
                                        font.family: "system-ui"
                                        font.pixelSize: 14
                                        color: "#1f2937"
                                        selectByMouse: true
                                        verticalAlignment: TextInput.AlignVCenter

                                        Text {
                                            anchors.left: parent.left
                                            anchors.verticalCenter: parent.verticalCenter
                                            text: "Enter your email"
                                            font.family: parent.font.family
                                            font.pixelSize: parent.font.pixelSize
                                            color: "#9ca3af"
                                            visible: emailField.text.length === 0 && !emailField.activeFocus
                                        }
                                    }
                                }
                            }
                        }

                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 8

                            RowLayout {
                                Text {
                                    text: "Password"
                                    font.family: "system-ui"
                                    font.pixelSize: 14
                                    font.weight: Font.Medium
                                    color: "#374151"
                                }

                                Item { Layout.fillWidth: true }

                                Rectangle {
                                    Layout.preferredWidth: 70
                                    Layout.preferredHeight: 24
                                    radius: 12
                                    color: "transparent"
                                    border.width: 1
                                    border.color: "#f59e0b"
                                    visible: !isSignupMode

                                    Text {
                                        anchors.centerIn: parent
                                        text: "Forgot?"
                                        color: "#f59e0b"
                                        font.family: "system-ui"
                                        font.pixelSize: 10
                                        font.weight: Font.Medium
                                    }

                                    MouseArea {
                                        anchors.fill: parent
                                        onClicked: {
                                            showPasswordReset = true
                                            showPasswordResetSuccess = false
                                            resetEmailField.text = emailField.text
                                        }
                                    }
                                }
                            }

                            Rectangle {
                                Layout.fillWidth: true
                                Layout.preferredHeight: 48
                                radius: 12
                                color: "#ffffff"
                                border.width: 2
                                border.color: passwordField.activeFocus ? (isSignupMode ? "#8b5cf6" : "#3b82f6") : "#e2e8f0"

                                Behavior on border.color { ColorAnimation { duration: 200 } }

                                RowLayout {
                                    anchors.fill: parent
                                    anchors.margins: 16
                                    spacing: 12

                                    Rectangle {
                                        width: 20
                                        height: 20
                                        radius: 10
                                        color: isSignupMode ? "#8b5cf6" : "#3b82f6"

                                        Text {
                                            anchors.centerIn: parent
                                            text: "🔒"
                                            font.pixelSize: 10
                                        }
                                    }

                                    TextInput {
                                        id: passwordField
                                        Layout.fillWidth: true
                                        font.family: "system-ui"
                                        font.pixelSize: 14
                                        color: "#1f2937"
                                        selectByMouse: true
                                        echoMode: TextInput.Password
                                        verticalAlignment: TextInput.AlignVCenter

                                        Text {
                                            anchors.left: parent.left
                                            anchors.verticalCenter: parent.verticalCenter
                                            text: isSignupMode ? "Create password (6+ chars)" : "Enter password"
                                            font.family: parent.font.family
                                            font.pixelSize: parent.font.pixelSize
                                            color: "#9ca3af"
                                            visible: passwordField.text.length === 0 && !passwordField.activeFocus
                                        }
                                    }
                                }
                            }

                            Rectangle {
                                Layout.fillWidth: true
                                Layout.preferredHeight: 4
                                radius: 2
                                color: "#e5e7eb"
                                visible: isSignupMode && passwordField.text.length > 0

                                Rectangle {
                                    width: Math.min(passwordField.text.length / 8, 1) * parent.width
                                    height: parent.height
                                    radius: 2
                                    color: passwordField.text.length >= 6 ? "#22c55e" : "#f59e0b"

                                    Behavior on width { NumberAnimation { duration: 200 } }
                                    Behavior on color { ColorAnimation { duration: 200 } }
                                }
                            }
                        }

                        Rectangle {
                            id: statusContainer
                            Layout.fillWidth: true
                            Layout.preferredHeight: Math.max(statusText.lineCount * 20 + 40, 80)
                            radius: 16
                            color: statusText.color === "#10b981" ? "#f0fdf4" :
                                   statusText.color === "#f59e0b" ? "#fffbeb" :
                                   statusText.color === "#fb923c" ? "#fff7ed" :
                                   statusText.color === "#3b82f6" ? "#eff6ff" :
                                   statusText.color === "#8b5cf6" ? "#faf5ff" : "#fef2f2"
                            border.width: 2
                            border.color: statusText.color === "#10b981" ? "#22c55e" :
                                         statusText.color === "#f59e0b" ? "#f59e0b" :
                                         statusText.color === "#fb923c" ? "#fb923c" :
                                         statusText.color === "#3b82f6" ? "#3b82f6" :
                                         statusText.color === "#8b5cf6" ? "#8b5cf6" : "#dc2626"
                            visible: statusText.visible

                            Rectangle {
                                anchors.centerIn: parent
                                anchors.verticalCenterOffset: 2
                                width: parent.width
                                height: parent.height
                                radius: parent.radius
                                color: "#10000000"
                                z: -1
                            }

                            RowLayout {
                                anchors.fill: parent
                                anchors.margins: 20
                                spacing: 15

                                Rectangle {
                                    Layout.preferredWidth: 40
                                    Layout.preferredHeight: 40
                                    Layout.alignment: Qt.AlignTop
                                    radius: 20
                                    color: statusText.color
                                    opacity: 0.2

                                    Text {
                                        id: statusIcon
                                        anchors.centerIn: parent
                                        text: "⚠️"
                                        font.pixelSize: 20
                                    }
                                }

                                Text {
                                    id: statusText
                                    Layout.fillWidth: true
                                    Layout.alignment: Qt.AlignVCenter
                                    font.family: "system-ui"
                                    font.pixelSize: 14
                                    font.weight: Font.Medium
                                    visible: false
                                    wrapMode: Text.WordWrap
                                    lineHeight: 1.4
                                    textFormat: Text.RichText
                                }
                            }
                        }

                        Rectangle {
                            id: loadingIndicator
                            Layout.alignment: Qt.AlignHCenter
                            Layout.preferredWidth: 32
                            Layout.preferredHeight: 32
                            radius: 16
                            color: "#f1f5f9"
                            border.width: 2
                            border.color: isSignupMode ? "#8b5cf6" : "#3b82f6"
                            visible: false

                            Rectangle {
                                anchors.centerIn: parent
                                width: 12
                                height: 12
                                radius: 6
                                color: isSignupMode ? "#8b5cf6" : "#3b82f6"

                                SequentialAnimation on scale {
                                    loops: Animation.Infinite
                                    running: loadingIndicator.visible
                                    NumberAnimation { to: 1.2; duration: 600 }
                                    NumberAnimation { to: 1.0; duration: 600 }
                                }
                            }

                            RotationAnimation on rotation {
                                loops: Animation.Infinite
                                running: loadingIndicator.visible
                                from: 0
                                to: 360
                                duration: 1500
                            }
                        }

                        Rectangle {
                            id: actionButton
                            Layout.fillWidth: true
                            Layout.preferredHeight: 48
                            radius: 12
                            color: actionButton.enabled ? (isSignupMode ? "#8b5cf6" : "#3b82f6") : "#d1d5db"
                            enabled: firebaseAuth.isReady && emailField.text.length > 0 && passwordField.text.length > 0

                            Behavior on color { ColorAnimation { duration: 200 } }

                            Text {
                                anchors.centerIn: parent
                                text: {
                                    if (!firebaseAuth.isReady) return "Initializing..."
                                    return isSignupMode ? "Create Account" : "Sign In"
                                }
                                font.family: "system-ui"
                                font.pixelSize: 14
                                font.weight: Font.Medium
                                color: "#ffffff"
                            }

                            MouseArea {
                                anchors.fill: parent
                                enabled: actionButton.enabled
                                onClicked: {
                                    console.log("🔘 Android Action button clicked:", isSignupMode ? "signup" : "login")

                                    if (emailField.text.length === 0) {
                                        showSmartErrorMessage("Please enter your email address to continue")
                                        return
                                    }

                                    if (passwordField.text.length === 0) {
                                        showSmartErrorMessage("Please enter your password to continue")
                                        return
                                    }

                                    if (!emailField.text.includes("@") || !emailField.text.includes(".")) {
                                        showSmartErrorMessage("Please enter a valid email address with @ and domain")
                                        return
                                    }

                                    if (isSignupMode && passwordField.text.length < 6) {
                                        showSmartErrorMessage("Password must be at least 6 characters for account security")
                                        return
                                    }

                                    actionButton.enabled = false
                                    loadingIndicator.visible = true
                                    showLoadingFeedback(isSignupMode ? "signup" : "login")

                                    if (isSignupMode) {
                                        firebaseAuth.signUp(emailField.text, passwordField.text)
                                    } else {
                                        firebaseAuth.login(emailField.text, passwordField.text)
                                    }
                                }
                            }
                        }

                        Item { Layout.fillHeight: true }
                    }
                }

                Rectangle {
                    Layout.alignment: Qt.AlignHCenter
                    Layout.preferredWidth: Math.min(300, parent.width - 40)
                    Layout.preferredHeight: 60
                    radius: 12
                    color: "#ffffff"
                    border.width: 1
                    border.color: "#e2e8f0"

                    ColumnLayout {
                        anchors.centerIn: parent
                        spacing: 4

                        Text {
                            text: "🔥 Status: " + (firebaseAuth.isReady ? "Ready ✅" : "Initializing... ⏳")
                            font.family: "system-ui"
                            font.pixelSize: 11
                            color: firebaseAuth.isReady ? "#22c55e" : "#f59e0b"
                            Layout.alignment: Qt.AlignHCenter
                            font.weight: Font.Medium
                        }

                        Text {
                            text: "ByteBite Android v1.0 | User: Welcome"
                            font.family: "system-ui"
                            font.pixelSize: 10
                            color: "#9ca3af"
                            Layout.alignment: Qt.AlignHCenter
                        }
                    }
                }

                Item { Layout.preferredHeight: 30 }
            }
        }
    }

    FirebaseAuth {
        id: firebaseAuth

        onSignupResult: function(success, message) {
            console.log("🔄 Android Signup result:", success, message)
            loadingIndicator.visible = false
            actionButton.enabled = true

            if (success) {
                statusText.text = "🎉 **Account Created Successfully!**\n\nWelcome to ByteBite!\nPlease check your email for verification."
                statusText.color = "#10b981"
                statusIcon.text = "🎉"
                statusText.visible = true
                statusContainer.visible = true
                messagePopAnimation.start()
                showEmailVerification = true
                firebaseAuth.sendEmailVerification()
            } else {
                showSmartErrorMessage(message)
            }
        }

        onLoginResult: function(success, message) {
            console.log("🔄 Android Login result:", success, message)
            loadingIndicator.visible = false
            actionButton.enabled = true

            if (success) {
                Qt.application.currentUserEmail = firebaseAuth.currentUserEmail
                Qt.application.currentUserDisplayName = firebaseAuth.userDisplayName
                Qt.application.isStudent = firebaseAuth.isStudent

                statusText.text = "🎉 **Login Successful!**\n\nWelcome back to ByteBite!\nTaking you to your dashboard..."
                statusText.color = "#10b981"
                statusIcon.text = "🎉"
                statusText.visible = true
                statusContainer.visible = true
                messagePopAnimation.start()

                Qt.callLater(function() {
                    stackView.push("selectrestaurant.qml")
                })
            } else {
                showSmartErrorMessage(message)
            }
        }

        onPasswordResetSent: function(success, message) {
            console.log("🔑 Android Password reset result:", success, message)

            if (success) {
                statusText.text = "📧 **Password Reset Sent!**\n\nCheck your email for reset instructions.\nDon't forget to check your spam folder!"
                statusText.color = "#10b981"
                statusIcon.text = "📧"
                statusText.visible = true
                statusContainer.visible = true
                messagePopAnimation.start()
                showPasswordResetSuccess = true
            } else {
                showSmartErrorMessage(message)
            }
        }

        onEmailVerificationSent: function(success, message) {
            console.log("📧 Android Email verification result:", success, message)
            if (success) {
                statusText.text = "📧 **Verification Email Sent!**\n\nCheck your inbox and click the verification link.\nIt may take a few minutes to arrive."
                statusText.color = "#10b981"
                statusIcon.text = "📧"
                statusText.visible = true
                statusContainer.visible = true
                messagePopAnimation.start()
            } else {
                showSmartErrorMessage("Failed to send verification email. Please try again.")
            }
        }
    }

    Component.onCompleted: {
        console.log("🔥 ByteBite Android Login Interface Loaded")
        console.log("✨ Enhanced Features: Detailed error messages, user guidance, visual feedback")
        console.log("📱 Responsive: Optimized for mobile devices")

        statusText.text = "👋 Please enter your email and password to continue."
        statusText.color = "#6b7280"
        statusIcon.text = "👋"
        statusText.visible = true
        statusContainer.visible = true
        statusHideTimer.restart()
    }
}
