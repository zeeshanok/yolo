import asyncio
import json
from websockets.server import serve, WebSocketServerProtocol

from classifier import get_bounding_boxes

async def on_connect(websocket: WebSocketServerProtocol):
    print(f"{websocket.host} connetecd")
    filename = ''
    async for message in websocket:
        if type(message) == bytes:
            result = await websocket.loop.run_in_executor(None, get_bounding_boxes, message)
            await websocket.send(f'result {json.dumps(result)}')

        elif message.startswith('sending '):
            filename = " ".join(message.split()[1:])
            print(f"about to receive {filename}")
            await websocket.send('ready')
       
async def main():
    async with serve(on_connect, 'localhost', '8000') as server:
        print("serving")
        await asyncio.Future()

asyncio.run(main())