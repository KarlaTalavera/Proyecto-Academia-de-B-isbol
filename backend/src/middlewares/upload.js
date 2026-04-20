const multer = require('multer')
const path   = require('path')
const fs     = require('fs')

const uploadsDir = path.join(__dirname, '../../uploads')
if (!fs.existsSync(uploadsDir)) fs.mkdirSync(uploadsDir, { recursive: true })

const storage = multer.diskStorage({
  destination: (_req, _file, cb) => cb(null, uploadsDir),
  filename: (req, file, cb) => {
    const ext    = path.extname(file.originalname).toLowerCase()
    const prefix = req.uploadPrefix || 'file'
    cb(null, `${prefix}-${req.params.id}-${Date.now()}${ext}`)
  },
})

const fileFilter = (_req, file, cb) => {
  const ext = path.extname(file.originalname).toLowerCase()
  if (['.jpg', '.jpeg', '.png'].includes(ext)) cb(null, true)
  else cb(new Error('Solo se permiten archivos JPG y PNG'))
}

module.exports = multer({ storage, fileFilter })
