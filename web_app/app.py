from flask import Flask, render_template, url_for, request, redirect, flash, jsonify
import sys
from mysql_connector import db
import json
import io
import base64
from base64 import b64encode

ALLOWED_EXTENSIONS = set(['png', 'jpg', 'jpeg', 'gif'])

def allowed_file(filename):
    return '.' in filename and filename.rsplit('.', 1)[1].lower() in ALLOWED_EXTENSIONS

app = Flask(__name__)
app.secret_key = "secret key"
app.config['MAX_CONTENT_LENGTH'] = 16 * 1024 * 1024



@app.route('/')
def index():
    return render_template('index.html')
    
@app.route('/new_product', methods=["POST", "GET"])
def new_product():
    if request.method == "POST":
        
        # handling images files
        if 'file' not in request.files:
            flash('No file part')
            return redirect(request.url)
        
        file = request.files['file'].read()
        file = base64.b64encode(file)

        
        # # print("file type=",str(type(file.read())), file=sys.stdout)
        
        # if file.filename == '':
            # flash('No image selected for uploading')
            # return redirect(request.url)
        
        # if file and allowed_file(file.filename):
            # # filename = secure_filename(file.filename)
            # # file.save(os.path.join(app.config['UPLOAD_FOLDER'], filename))
            # #print('upload_image filename: ' + filename)
            # # flash('Image successfully uploaded and displayed below')
            # pass
        # else:
            # flash('Allowed image types are - png, jpg, jpeg, gif')
            # return redirect(request.url)
    
        
        cursor = db.cursor()

        form_data = (
            request.form["produce_name"],
            request.form["unit_price"],
            request.form["produce_type"],
            file
        )        

        cursor.execute(
        """
        INSERT INTO produce(
            produce_name, 
            unit_price, 
            produce_type,
            produce_image
        ) values (%s, %s, %s, %s)
        """, form_data)
        db.commit()
        
        return render_template('new_product.html')
      
    else:
        return render_template('new_product.html')


@app.route('/produce_data', methods=['GET'])
def produce_data():
    from PIL import Image
    from base64 import b64encode

    db.commit()
    cur = db.cursor()
    cur.execute("SELECT produce_id, produce_name, unit_price, produce_type, produce_image FROM produce")
    row_headers=[x[0] for x in cur.description] #this will extract row headers
    rv = cur.fetchall()
    json_data=[]
    
    for row in rv:
        if row[4] == None:
            # b64 byte image (ori) 
            # image = Image.open(io.BytesIO(b64_str))
            # image.show()
            json_data.append(
                {
                    row_headers[0] : row[0],
                    row_headers[1] : row[1],
                    row_headers[2] : row[2],
                    row_headers[3] : row[3],
                    row_headers[4] : "NONE"
                }
            )
        else:
            b64_img = row[4]
            
            # utf-8 string (transform)
            utf_8_img = row[4].decode("utf-8")
            
            # b64 byte image (ori)
            b64_img = utf_8_img.encode("utf-8")
            
            # b64 string
            b64_str = base64.b64decode(b64_img)
        
            json_data.append(
                    {
                        row_headers[0] : row[0],
                        row_headers[1] : row[1],
                        row_headers[2] : row[2],
                        row_headers[3] : row[3],
                        row_headers[4] : utf_8_img
                    }
                )
            

    return json.dumps(json_data)
        
    


if __name__ == "__main__":
    app.config['TEMPLATES_AUTO_RELOAD'] = True
    app.run(host='0.0.0.0', port='8080', debug=True)
    
    
def from_utf_to_b64(utf):
    return b64encode(utf.encode('utf-8'))
