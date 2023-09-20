from ultralytics import YOLO
from torch import Tensor
from PIL import Image, ImageDraw
import io

model = YOLO("yolov8n.pt")


def get_bounding_boxes(b: bytes) -> list[dict[str, list[int, int, int, int] | str]]:
    print("processing")
    img = Image.open(io.BytesIO(b))
    results = model(img, verbose=False)

    return {
        "predictions": [
            {
                "coords": list(int(c) for c in box.xyxy[0]),
                "name": model.names[int(cls)],
            }
            for box, cls in zip(results[0].boxes, results[0].boxes.cls)
        ],
        "resolution": list(img.size),
    }


if __name__ == "__main__":
    for box in get_bounding_boxes("flower1.jpg"):
        print(box)
