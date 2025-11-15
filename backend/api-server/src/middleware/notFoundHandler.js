const notFoundHandler = (req, res) => {
  res.status(404).json({
    success: false,
    error: {
      message: `Cannot ${req.method} ${req.path}`,
      statusCode: 404
    }
  });
};

module.exports = { notFoundHandler };
