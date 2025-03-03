import http from 'k6/http';
import { sleep } from 'k6';

export default function() {
  let response = http.get('http://app_ip:app_port/api/health');
  console.log(response.error_code);
  sleep(1);
}