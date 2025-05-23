# Part of Odoo. See LICENSE file for full copyright and licensing details.

from odoo import fields, models

class EfakturUomCode(models.Model):
    _name = "l10n_id_efaktur_coretax.uom.code"
    _description = "UOM categorization according to E-Faktur"

    code = fields.Char()
    name = fields.Char()

    def name_get(self):
        result = []
        for record in self:
            result.append((record.id, f"{record.name} ({record.code})"))
        return result
