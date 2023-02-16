from fastapi import FastAPI, WebSocket, WebSocketDisconnect
from fastapi.staticfiles import StaticFiles
from starlette.responses import FileResponse 
from qa import askQuestion
import json

app = FastAPI()
app.mount("/static", StaticFiles(directory="public"), name="static")

@app.get("/")
async def root():
    return FileResponse('public/index.html')

# @app.post("/ask")
# async def ask(request: Request):
#     result = askQuestion(request.question)
#     return {
#         'answer': result['answer'],
#         'sources': result['sources']
#     }

@app.websocket("/ask")
async def websocket_endpoint(websocket: WebSocket):
    await websocket.accept()
    try:
        while True:
            question = await websocket.receive_text()
            result = askQuestion(question)
            result_json = json.dumps({
                'question': question,
                'answer': result['answer'],
                'sources': result['sources']
            })
            await websocket.send_text(result_json)
    except WebSocketDisconnect:
        pass
