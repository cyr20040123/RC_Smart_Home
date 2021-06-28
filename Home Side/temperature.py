import Adafruit_DHT
import time

def getTemperature():
	cur_time = time.strftime("%b/%d/%Y %a %H:%M", time.localtime())
	try:
		sensor = Adafruit_DHT.DHT11
		humidity, temperature = Adafruit_DHT.read_retry(sensor,17)
		return {"temperature":int(temperature),"humidity":int(humidity),"time":cur_time}
	except Exception:
		return {"temperature":"Err","humidity":"Err","time":cur_time}
