import QtQuick
import QtQuick3D
import QtQuick3D.AssetUtils
import QtQuick3D.Helpers
import Quickshell
import Quickshell.Wayland
import "../../global"

PanelWindow {
    anchors {
        left: true
        right: true
        top: true
        bottom: true
    }

    color: Theme[Config.wallpaper.background]
    WlrLayershell.layer: WlrLayer.Bottom
    exclusionMode: ExclusionMode.Ignore

    View3D {
        id: root
        anchors.fill: parent
        camera: camera

        environment: ExtendedSceneEnvironment {
            backgroundMode: SceneEnvironment.Color
            clearColor: Theme[Config.wallpaper.background]

            lutEnabled: true
            lutSize: 16
            lutFilterAlpha: 1

            lutTexture: Texture {
                source: Theme.lutPath
            }
        }

        PointLight {
            position: Qt.vector3d(0, 0, 20)
            castsShadow: true
            brightness: 0.8
        }

        Node {
            id: cameraRig

            property real pitch: -pointer.normalizedY * 3
            property real yaw: pointer.normalizedX * 4

            eulerRotation: Qt.vector3d(pitch, yaw, 0)

            PerspectiveCamera {
                id: camera

                fieldOfView: 45
                z: 20
            }

            Behavior on pitch {
                NumberAnimation {
                    duration: 400
                    easing.type: Easing.OutCubic
                }
            }

            Behavior on yaw {
                NumberAnimation {
                    duration: 400
                    easing.type: Easing.OutCubic
                }
            }
        }

        RuntimeLoader {
            id: nixosIcon
            source: Qt.resolvedUrl("../../assets/nixos_3d_icon.glb")
        }

        Model {
            source: "#Rectangle"
            receivesShadows: true
            position: Qt.vector3d(0, 0, -50)
            scale: Qt.vector3d(10, 10, 10)
            materials: PrincipledMaterial {
                baseColor: Theme[Config.wallpaper.background]
                roughness: 1.0
            }
        }
    }

    MouseArea {
        id: pointer

        anchors.fill: parent
        hoverEnabled: true
        acceptedButtons: Qt.NoButton

        readonly property real normalizedX: containsMouse && width > 0 ? (mouseX / width - 0.5) * 2 : 0
        readonly property real normalizedY: containsMouse && height > 0 ? (mouseY / height - 0.5) * 2 : 0
    }
}
