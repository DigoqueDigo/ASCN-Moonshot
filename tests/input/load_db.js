import http from 'k6/http';
import { randomIntBetween } from 'https://jslib.k6.io/k6-utils/1.2.0/index.js';

export default function () {

  const login_url = 'http://app_ip:app_port/api/auth/login/';
  const recovery_url = 'http://app_ip:app_port/api/recoveries/';
  const certificate_url = 'http://app_ip:app_port//api/certificates/';

  const people = [
    {'name': 'Diogo Marques', 'date_of_birth': '2000-01-01', 'identifier': '1111', 'sex': 'male'},
    {'name': 'Ivan Ribeiro', 'date_of_birth': '2000-01-01', 'identifier': '2222', 'sex': 'male'},
    {'name': 'Luís Ribeiro', 'date_of_birth': '2000-01-01', 'identifier': '3333', 'sex': 'male'},
    {'name': 'Rui Cerqueira', 'date_of_birth': '2000-01-01', 'identifier': '4444', 'sex': 'male'},
    {'name': 'Guilherme Rio', 'date_of_birth': '2000-01-01', 'identifier': '5555', 'sex': 'male'},
  ];

  let payload = JSON.stringify({
    email: 'notifier@moonshot.pt',
    password: 123456,
  });

  let params = {
    headers: {
      'Cache-Control': 'no-cache',
      'Content-Type': 'application/json; charset=UTF-8',
    },
  };

  let response = http.post(login_url,payload,params);
  console.log(response.error_code);

  const access = JSON.parse(response.body).access;
  const index = randomIntBetween(0, people.length);

  payload = JSON.stringify({
    'disease': 'XN109',
    'first_positive_test_date': '2024-08-21',
    'country': 'PT',
    'person_identification': people[index]
  });

  params = {
    headers: {
      'Cache-Control': 'no-cache',
      'Content-Type': 'application/json; charset=UTF-8',
      'Authorization': `Bearer ${access}`
    },
  };

  response = http.post(recovery_url,payload,params);
  console.log(response.error_code);

//  const uvci = JSON.parse(response.body).uvci;
//  response = http.get(certificate_url + uvci,params);
//  console.log(response.error_code);
}