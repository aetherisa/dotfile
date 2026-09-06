import QtQuick
import QtQuick3D
import QtQuick3D.AssetUtils
import QtQuick3D.Helpers
import Quickshell
import Quickshell.Wayland
import qs.global

PanelWindow {
    anchors {
        left: true
        right: true
        top: true
        bottom: true
    }

    color: Theme[Config.colors.background]
    WlrLayershell.layer: WlrLayer.Bottom
    exclusionMode: ExclusionMode.Ignore

    View3D {
        id: root

        anchors.fill: parent
        camera: camera

        environment: ExtendedSceneEnvironment {
            backgroundMode: SceneEnvironment.Color
            clearColor: Theme[Config.colors.background]

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

            property real pitch: 0
            property real yaw: 0

            function moveToward(x, y): void {
                yaw = (x / pointer.width - 0.5) * 8
                pitch = -(y / pointer.height - 0.5) * 6
            }

            eulerRotation: Qt.vector3d(pitch, yaw, 0)

            PerspectiveCamera {
                id: camera

                fieldOfView: 45
                z: 20
            }

            Behavior on pitch {
                SpringAnimation {
                    spring: 2
                    damping: 0.25
                    epsilon: 0.01
                }
            }

            Behavior on yaw {
                SpringAnimation {
                    spring: 2
                    damping: 0.25
                    epsilon: 0.01
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
                baseColor: Theme[Config.colors.background]
                roughness: 1.0
            }
        }
    }

    MouseArea {
        id: pointer

        anchors.fill: parent
        acceptedButtons: Qt.LeftButton

        onClicked: mouse => cameraRig.moveToward(mouse.x, mouse.y)
    }
}
