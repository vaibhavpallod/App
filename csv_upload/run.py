from app.main import app
import json
from flask import request
import pandas as pd

@app.route('/upload',methods=["POST"])
def post():
    file = request.files['file']
    aa=pd.read_csv(file,encoding='latin-1',on_bad_lines='skip')
    print(aa)
    # excel_data_df = pandas.read_excel(file)
    json_str = aa.to_json(orient='records')
    return json_str
    # a=file.read()
    # print(type(a))
    # str = unicode(a, errors='replace')
    # print(type(str))
    # a=str
    # arr=a.split(b'\n')
    # data=[]
    # daa=['Name','Phone','Email','Address']
    # print(len(arr))
    # for i in arr:
    #     aa=i.split(b',')
    #     print(len(aa))
    #     d={}
    #     cnt=0
    #     for j in aa:
    #         d[daa[cnt]]=j.decode('utf-8')
    #         cnt=cnt+1
    #     data.append(d)
    # print(data)
    # print(file.read())
    #dd={}
    # dd['data']=json.dumps(data)
    #dd=jsonify(data)
    # return json.dumps(data)

if __name__ == "__main__":
  app.run()