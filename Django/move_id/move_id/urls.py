"""
URL configuration for move_id project.

The `urlpatterns` list routes URLs to views. For more information please see:
    https://docs.djangoproject.com/en/5.0/topics/http/urls/
Examples:
Function views
    1. Add an import:  from my_app import views
    2. Add a URL to urlpatterns:  path('', views.home, name='home')
Class-based views
    1. Add an import:  from other_app.views import Home
    2. Add a URL to urlpatterns:  path('', Home.as_view(), name='home')
Including another URLconf
    1. Import the include() function: from django.urls import include, path
    2. Add a URL to urlpatterns:  path('blog/', include('blog.urls'))
"""
from django.contrib import admin
from django.urls import path
from .views import RegisterAPI
from .views import LoginAPI
from .views import NotifierAPI
from .views import LocationGetterAPI, ClassificationAPI

urlpatterns = [
    path('admin/', admin.site.urls),
    path('registerAPI/',RegisterAPI.as_view()),
    path('loginAPI/',LoginAPI.as_view()),  
    path('removeNotifierAPI/',NotifierAPI.as_view()),   
    path('addNotifierAPI/',NotifierAPI.as_view()),    
    path('LocationGetterAPI/',LocationGetterAPI.as_view()),
    path('notificationHistory/',ClassificationAPI.as_view())
]
