import cv2
import cvzone
from cvzone.FaceMeshModule import FaceMeshDetector

CAM_NUMBER = 0
cap = cv2.VideoCapture(CAM_NUMBER)
detector = FaceMeshDetector(maxFaces=1)

while True:
    success, img = cap.read()
    img, faces = detector.findFaceMesh(img, draw=False)
    if faces:
        face = faces[0]
        point_left_eye = face[145]
        point_right_eye = face[374]
        # cv2.line(img, point_left_eye, point_right_eye, (0, 255, 0), 2)
        # cv2.circle(img, point_left_eye, 5, (0, 0, 255), cv2.FILLED)
        # cv2.circle(img, point_right_eye, 5, (0, 0, 255), cv2.FILLED)
        w,_ = detector.findDistance(point_left_eye, point_right_eye)
        W = 6.3
        f = 940
        d = (W * f) / w
        print(d)
        cvzone.putTextRect(img, f'Depth: {int(d)}cm',
                           (face[10][0] - 100, face[10][1] - 50),
                           scale=2)
    cv2.imshow("Image", img)
    cv2.waitKey(1)