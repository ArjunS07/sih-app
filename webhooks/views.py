from django.http import HttpResponse
from django.views.decorators.csrf import csrf_exempt

@csrf_exempt
def test(request):
    if request.method == 'POST':
        print("Data received from Webhook is: ", request.body)
        return HttpResponse("Webhook received!")