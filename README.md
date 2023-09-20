# yolo
An image classifier app made with flutter and a python backend

## Running
The server must be running before opening the app

### To run the server:
The packages that are needed to work are listed in `requirements.txt`. Run the following:

```sh
cd server
# You can create a virtual environment here if you want
pip install -r requirements.txt
python main.py
```

### To run the app
Install flutter and run
```sh
cd yolo_frontend
flutter run --release
```