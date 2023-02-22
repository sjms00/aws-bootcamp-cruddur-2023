docker build -t  backend-flask ./backend-flask
docker container run --rm -p 4567:4567 -e FRONTEND_URL='*' -e BACKEND_URL='*' -d backend-flask
docker build -t  frontend-react-js ./frontend-react-js
docker container run --rm -p 3000:3000 -d frontend-react-js