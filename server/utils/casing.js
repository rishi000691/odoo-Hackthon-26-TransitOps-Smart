const isPlainObject = (obj) => {
  if (obj === null || typeof obj !== 'object') return false;
  
  // Exclude database Decimal objects and Dates
  if (obj.constructor && (obj.constructor.name === 'Decimal' || obj.constructor.name === 'Date')) {
    return false;
  }
  
  const proto = Object.getPrototypeOf(obj);
  return proto === null || proto === Object.prototype;
};

const snakeToCamel = (obj) => {
  if (Array.isArray(obj)) {
    return obj.map(v => snakeToCamel(v));
  } else if (isPlainObject(obj)) {
    return Object.keys(obj).reduce((result, key) => {
      const camelKey = key.replace(/_([a-z0-9])/g, (_, letter) => letter.toUpperCase());
      result[camelKey] = snakeToCamel(obj[key]);
      return result;
    }, {});
  }
  return obj;
};

const camelToSnake = (obj) => {
  if (Array.isArray(obj)) {
    return obj.map(v => camelToSnake(v));
  } else if (isPlainObject(obj)) {
    return Object.keys(obj).reduce((result, key) => {
      const snakeKey = key.replace(/[A-Z]/g, letter => `_${letter.toLowerCase()}`);
      result[snakeKey] = camelToSnake(obj[key]);
      return result;
    }, {});
  }
  return obj;
};

module.exports = {
  snakeToCamel,
  camelToSnake
};
