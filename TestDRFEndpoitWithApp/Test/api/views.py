from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework import status

class BasicAPI(APIView):
    
    def get(self, request):
        data = {
            'first_name': 'grant',
            'last_name': 'zhu'
        }
        return Response(data)
    
    # HERE IS THE POST API
    def post(self, request):
        req_data = request.data
        data = {
            'first_name': req_data.get('first_name'),
            'last_name': req_data.get('last_name')
        }
        return Response(data, status=status.HTTP_200_OK)
    