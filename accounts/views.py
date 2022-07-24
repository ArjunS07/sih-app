from rest_framework.authtoken.views import ObtainAuthToken
from rest_framework.authtoken.models import Token
from rest_framework.response import Response
from rest_framework.views import APIView
from rest_framework import status
from django.http import HttpResponse

from rest_framework.views import APIView

from rest_framework.renderers import JSONRenderer
from rest_framework.response import Response
from rest_framework import status


from . import serializers

class CustomAuthToken(ObtainAuthToken):

    def post(self, request, *args, **kwargs):
        serializer = self.serializer_class(data=request.data,
                                           context={'request': request})
        serializer.is_valid(raise_exception=True)
        user = serializer.validated_data['user']
        token, created = Token.objects.get_or_create(user=user)
        return Response({
            'token': token.key,
            'user_id': user.pk,
            'email': user.email
        })
from django.contrib.auth import get_user_model
User = get_user_model()

class UserView(APIView):
     def get(self, request, format=None):
        account_id = request.query_params.get('id', None)
        try:
            account = User.objects.get(id=account_id)
        except:
            return Response(status=status.HTTP_404_NOT_FOUND)
        serialized_account = serializers.UserModelSerializer(account)
        res = JSONRenderer().render(serialized_account.data)
        return HttpResponse(res, content_type='application/json', status=status.HTTP_200_OK)