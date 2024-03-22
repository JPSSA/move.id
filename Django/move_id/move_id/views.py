import json
from django.http import JsonResponse
from move_id_app.mqtt import client as mqtt_client
from rest_framework.views import APIView
from django.contrib.auth.models import User

#def publish_message(request):
#    request_data = json.loads(request.body)
#    rc, mid = mqtt_client.publish(request_data['topic'], request_data['msg'])
#    return JsonResponse({'code': rc})


class RegisterAPI(APIView):

    def post(self,request):

        if request.method == 'POST':

            print("Entrou no POST!!")
            
            # Getting the data from the register
            data = json.loads(request.body)
            first_name = data.get('first_name')
            last_name = data.get('last_name')
            username = data.get('username')
            email = data.get('email')
            password = data.get('password')

            # Checking if the email exists
            if User.objects.filter(email=email).exists():
                print("Email ja esta usado")
                return JsonResponse({'error': 'Email already in use'}, status=400)

            # Creating the user
            user = User.objects.create_user(username=username, email=email, password=password)
            user.first_name = first_name
            user.last_name = last_name

            # Saving the user to the database
            user.save()

            return JsonResponse({'message': 'User created successfully'}, status=200)
        else:
            print("Erro no metodo")
            return JsonResponse({'error': 'Method not allowed'}, status=405)