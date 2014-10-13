import re

PDB = re.compile('^[0-9][A-z0-9]{3}$')

MAX_NTS = 20


class ValidationError(Exception):
    """Raised when a search is invalid or cannot be santized.
    """
    pass


def santize_search(search):
    pass


def santize_given(given):
    data = {pdbs: {}, cells: {}, size: None}

    for raw in given.get('pdbs', []):
        for pdb in raw.split(','):
            if PDB.match(pdb):
                data['pdbs'][pdb] = True

    if given['size']:
        size = int(given['size'])
        data['size'] = size

        if size > MAX_NTS:
            raise ValidationError("Too many NTs")

        rows = given.get('rows', [])
        if len(rows) > size:
            rows = rows[0:size]

        if len(rows) < size:
            empty_row = ','.join([''] * size)
            rows.extend([empty_row] * (size - len(rows)))

        for row, raw in enumerate(rows):
            cells = raw.split(',')
            if len(cells) > size:
                cells = cells[0:size]
            if len(cells) < size:
                cells.extend([None] * (size - len(cells)))

            for column, cell in enumerate(cells):
                if cell == '':
                    cell = None
                data['cells'][row][column] = cell

    return data
