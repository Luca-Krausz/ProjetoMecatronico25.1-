import cv2
import numpy as np

image = cv2.imread('imagens\imgteste7.jpg')
original = image.copy()

gray = cv2.cvtColor(image, cv2.COLOR_BGR2GRAY)
blurred = cv2.GaussianBlur(gray, (5, 5), 0)

edges = cv2.Canny(blurred, 30, 90)

contours, _ = cv2.findContours(edges, cv2.RETR_EXTERNAL, cv2.CHAIN_APPROX_SIMPLE)

max_area = 0
best_rect = None

for contour in contours:
    area = cv2.contourArea(contour)
    if area < 100:
        continue
        
    peri = cv2.arcLength(contour, True)
    approx = cv2.approxPolyDP(contour, 0.1 * peri, True)
    
    if len(approx) == 4 and area > max_area:
        max_area = area
        best_rect = approx
        print(f"Found rectangle with area {max_area}")

if best_rect is not None:
    
    cv2.drawContours(image, [best_rect], -1, (0, 255, 0), 2)
    
    x, y, w, h = cv2.boundingRect(best_rect)
    
    roi = original[y:y+h, x:x+w]
    roi_gray = cv2.cvtColor(roi, cv2.COLOR_BGR2GRAY)
    roi_gray = cv2.equalizeHist(roi_gray)
    roi_blur = cv2.GaussianBlur(roi_gray, (5, 5), 0)
    
    circles = cv2.HoughCircles(
        roi_blur, 
        cv2.HOUGH_GRADIENT, 
        dp=1, 
        minDist=20, 
        param1=50, 
        param2=30, 
        minRadius=5, 
        maxRadius=30
    )
    
    if circles is not None:
        circles = np.round(circles[0, :]).astype("int")
        
        roi_with_circles = roi.copy()
        for (cx, cy, r) in circles:
            cv2.circle(roi_with_circles, (cx, cy), r, (0, 255, 0), 2)
            cv2.circle(roi_with_circles, (cx, cy), 2, (0, 0, 255), 3)
            
            abs_x = x + cx
            abs_y = y + cy
            print(f"Well at coordinates: ({abs_x}, {abs_y}), radius: {r}")
        

        cv2.namedWindow("edges", cv2.WINDOW_NORMAL)
        cv2.namedWindow("Detected Tray", cv2.WINDOW_NORMAL)
        cv2.namedWindow("Detected Wells", cv2.WINDOW_NORMAL)
        
        cv2.imshow("edges", edges)
        cv2.imshow("Detected Tray", image)
        cv2.imshow("Detected Wells", roi_with_circles)
        cv2.waitKey(0)
        cv2.destroyAllWindows()
    else:
        print("No circles detected in the sample tray")
else:
    print("Sample tray not detected")