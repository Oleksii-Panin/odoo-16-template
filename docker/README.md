docker build -t {name}/odoo_v16:odoo_v16 -f docker/odoo/Dockerfile ./

docker build -t {name}/odoo_v16:pg_v14 -f docker/pg/Dockerfile  ./

You can push this images in this registry repository - {name}/odoo_v16:

docker push {name}/odoo_v16:odoo_v16

docker push {name}/odoo_v16:pg_v14
