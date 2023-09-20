from flask import Flask
from flask_restful import Api, Resource, reqparse
import werkzeug

import classifier

app = Flask(__name__)
api = Api(app)

class ImageClassifier(Resource):
    def post(self):
        parse = reqparse.RequestParser()
        parse.add_argument('file', type=werkzeug.datastructures.FileStorage, location='files')
        args = parse.parse_args()
        print(args)
        # image_file = args['file']
        # image_file.save("image.jpg")
        # filename = 'flower.jpg'
        # xyxy = classifier.get_bounding_boxes(filename)
        # return {
        #     "coords": xyxy
        # }
        

api.add_resource(ImageClassifier, '/classify')

if __name__ == '__main__':
    app.run(debug=True, host='0.0.0.0')